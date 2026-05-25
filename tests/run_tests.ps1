$ErrorActionPreference = 'Stop'

function Build-Targets {
  Write-Host '== Build =='
  & g++ -std=c++17 -Wall -Wextra -pedantic sha_procedure.cpp -o sha256
  & g++ -std=c++17 -Wall -Wextra -pedantic file_integrity.cpp -o file_integrity
  & g++ -std=c++17 -Wall -Wextra -pedantic password_hash.cpp -o password_hash
  & g++ -std=c++17 -Wall -Wextra -pedantic salted_password_hash.cpp -o salted_password_hash
}

function Assert-True($cond, [string]$msg) {
  if (-not $cond) {
    Write-Host "[FAIL] $msg"
    exit 1
  }
}

function Test-ShaCompile {
  Write-Host '== 1. SHA compile =='
  Assert-True (Test-Path -Path .\sha256 -PathType Leaf) 'Missing sha256 executable'
  Assert-True (Test-Path -Path .\file_integrity -PathType Leaf) 'Missing file_integrity executable'
  Assert-True (Test-Path -Path .\password_hash -PathType Leaf) 'Missing password_hash executable'
  Assert-True (Test-Path -Path .\salted_password_hash -PathType Leaf) 'Missing salted_password_hash executable'
  Write-Host '[PASS] SHA programs compile successfully.'
}

function Test-KnownVectors {
  Write-Host '== 2. Known answer vectors =='
  $emptyExpected = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  $abcExpected = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'

  $emptyActual = (& .\sha256 --hash-string "")
  Assert-True ($emptyActual.Trim() -eq $emptyExpected) "Empty string vector mismatch. expected=$emptyExpected actual=$emptyActual"

  $abcActual = (& .\sha256 --hash-string "abc")
  Assert-True ($abcActual.Trim() -eq $abcExpected) "abc vector mismatch. expected=$abcExpected actual=$abcActual"

  & .\sha256 --self-test | Out-Null
  Write-Host '[PASS] SHA-256 known answer tests passed.'
}

function Test-FileIntegrityTamper {
  Write-Host '== 3. File integrity tamper negative =='
  $tmpFile = New-TemporaryFile
  try {
    Set-Content -Path $tmpFile.FullName -Value 'FIT4012 file integrity test' -NoNewline
    $expectedHash = (& .\sha256 --hash-file $tmpFile.FullName).Trim()

    & .\file_integrity $tmpFile.FullName $expectedHash | Out-Null

    Add-Content -Path $tmpFile.FullName -Value "`ntamper: seda 1 byte / flip 1 byte"

    $ok = $true
    try {
      & .\file_integrity $tmpFile.FullName $expectedHash | Out-Null
      $ok = $false
    } catch {
      $ok = $true
    }
    Assert-True $ok 'Tamper test should fail after file is changed'

    Write-Host '[PASS] Tamper / flip 1 byte negative test passed.'
  } finally {
    Remove-Item -Force $tmpFile.FullName -ErrorAction SilentlyContinue
  }
}

function Test-PasswordHash {
  Write-Host '== 4. Password hash (register/login + wrong password) =='
  $hashFile = 'test_password.hash'
  if (Test-Path $hashFile) { Remove-Item $hashFile -Force }

  & .\password_hash register 'student-password-123' $hashFile | Out-Null
  Assert-True (Test-Path $hashFile) 'Password hash file was not created'
  Assert-True ((Get-Item $hashFile).Length -gt 0) 'Password hash file was empty'

  & .\password_hash login 'student-password-123' $hashFile | Out-Null

  $rejected = $false
  try {
    & .\password_hash login 'wrong password / sai mật khẩu' $hashFile | Out-Null
    $rejected = $false
  } catch {
    $rejected = $true
  }
  Assert-True $rejected 'Wrong password should be rejected'

  Write-Host '[PASS] Password hash and wrong password negative test passed.'
}

function Test-SaltedPassword {
  Write-Host '== 5. Salted password (different salt => different record) =='
  $hashFile1 = 'test_password_salted_1.hash'
  $hashFile2 = 'test_password_salted_2.hash'

  if (Test-Path $hashFile1) { Remove-Item $hashFile1 -Force }
  if (Test-Path $hashFile2) { Remove-Item $hashFile2 -Force }

  & .\salted_password_hash register 'same-password' $hashFile1 | Out-Null
  & .\salted_password_hash register 'same-password' $hashFile2 | Out-Null

  Assert-True (Test-Path $hashFile1 -PathType Leaf) 'Salted hash file 1 was not created'
  Assert-True (Test-Path $hashFile2 -PathType Leaf) 'Salted hash file 2 was not created'
  Assert-True ((Get-Item $hashFile1).Length -gt 0) 'Salted hash file 1 was empty'
  Assert-True ((Get-Item $hashFile2).Length -gt 0) 'Salted hash file 2 was empty'

  # compare raw files
  $bytes1 = [System.IO.File]::ReadAllBytes($hashFile1)
  $bytes2 = [System.IO.File]::ReadAllBytes($hashFile2)
  $same = ($bytes1.Length -eq $bytes2.Length) -and ($bytes1 -join ',' -eq $bytes2 -join ',')
  Assert-True (-not $same) 'Same password should not produce the same salted hash record'

  & .\salted_password_hash login 'same-password' $hashFile1 | Out-Null

  $rejected = $false
  try {
    & .\salted_password_hash login 'wrong password / sai mật khẩu' $hashFile1 | Out-Null
    $rejected = $false
  } catch {
    $rejected = $true
  }
  Assert-True $rejected 'Wrong password should be rejected in salted login'

  Write-Host '[PASS] Salted password test passed.'
}

Build-Targets
Test-ShaCompile
Test-KnownVectors
Test-FileIntegrityTamper
Test-PasswordHash
Test-SaltedPassword

Write-Host '=== ALL TESTS PASSED ==='

