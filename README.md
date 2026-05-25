[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/1qIFamCm)
# FIT4012 - Lab 7: SHA-256 Starter Repository

## 1. Cấu trúc repo

```text
.
├── .github/
│   ├── scripts/
│   │   └── check_submission.sh
│   └── workflows/
│       └── ci.yml
├── docs/
│   └── sha-code-notes.md
├── logs/
│   ├── .gitkeep
│   ├── README.md
│   └── sample-run.log
├── scripts/
│   └── run_sample.sh
├── tests/
│   ├── test_sha_compile.sh
│   ├── test_known_vectors.sh
│   ├── test_file_integrity_tamper.sh
│   ├── test_password_hash.sh
│   └── test_salted_password.sh
├── .gitignore
├── CMakeLists.txt
├── Makefile
├── README.md
├── file_integrity.cpp
├── password_hash.cpp
├── report-1page.md
├── salted_password_hash.cpp
├── sha256_lib.h
├── sha_procedure.cpp
└── structure.h
```

## 2. Cách chạy chương trình

### Cách 1: Dùng Makefile

```bash
make
./sha256 --self-test
./sha256 --hash-string "abc"
```

### Cách 2: Chạy script mẫu

```bash
bash scripts/run_sample.sh
```

### Cách 3: Biên dịch trực tiếp

```bash
g++ -std=c++17 -Wall -Wextra -pedantic sha_procedure.cpp -o sha256
g++ -std=c++17 -Wall -Wextra -pedantic file_integrity.cpp -o file_integrity
g++ -std=c++17 -Wall -Wextra -pedantic password_hash.cpp -o password_hash
g++ -std=c++17 -Wall -Wextra -pedantic salted_password_hash.cpp -o salted_password_hash
```

### Cách 4: Dùng CMake

```bash
cmake -S . -B build
cmake --build build
./build/sha256 --self-test
```

## 3. Input / Đầu vào

Repo có 4 chương trình chính:

- `sha_procedure.cpp`: băm chuỗi nhập từ bàn phím hoặc từ tham số dòng lệnh.
- `file_integrity.cpp`: đọc nội dung một file và tính SHA-256 để kiểm tra toàn vẹn.
- `password_hash.cpp`: băm mật khẩu và lưu hash vào file.
- `salted_password_hash.cpp`: băm mật khẩu với salt, lưu theo định dạng `salt:hash`.

Ví dụ input dạng chuỗi:

```bash
./sha256 --hash-string "abc"
```

Ví dụ input dạng file:

```bash
printf "FIT4012 SHA sample\n" > sample.txt
./sha256 --hash-file sample.txt
```

## 4. Output / Đầu ra

- `sha256` in giá trị SHA-256 dạng hexa 64 ký tự.
- `file_integrity` in `[PASS]` nếu hash hiện tại trùng với hash mong muốn, `[FAIL]` nếu file đã bị thay đổi.
- `password_hash` lưu hash mật khẩu vào `password.hash` hoặc file do người dùng chỉ định.
- `salted_password_hash` lưu bản ghi dạng `salt:hash`, trong đó cùng một mật khẩu nhưng salt khác nhau sẽ tạo ra bản ghi khác nhau.

## 5. Padding đang dùng

SHA-256 không dùng padding kiểu zero padding như AES block demo. Thuật toán dùng padding chuẩn Merkle-Damgård:

1. Thêm byte `0x80`, tương ứng bit `1` rồi các bit `0`.
2. Thêm các byte `0x00` cho đến khi độ dài dữ liệu đạt `56 mod 64` byte.
3. Thêm độ dài ban đầu của thông điệp dưới dạng số nguyên 64-bit Big Endian.

Nhờ vậy, dữ liệu đầu vào được chia thành các khối 512 bit trước khi đưa vào hàm nén `sha256_transform()`.

## 6. Tests bắt buộc

Repo đã chuẩn bị 5 test shell cơ bản:

- `tests/test_sha_compile.sh`
- `tests/test_known_vectors.sh`
- `tests/test_file_integrity_tamper.sh`
- `tests/test_password_hash.sh`
- `tests/test_salted_password.sh`

Chạy toàn bộ test:

```bash
make test
```

## 7. Logs / Minh chứng

Thư mục `logs/` dùng để lưu minh chứng học tập, ví dụ:

- output khi build chương trình
- output khi chạy known answer test vector
- output khi kiểm tra toàn vẹn file thành công
- output khi phát hiện file bị sửa/tamper
- output khi kiểm tra mật khẩu đúng/sai
- output khi cùng mật khẩu nhưng salt khác nhau tạo ra hash khác nhau

## 8. Ethics & Safe use

- Chỉ dùng repo này cho mục tiêu học tập, kiểm tra toàn vẹn dữ liệu và minh họa thuật toán băm.
- Không dùng hash mật khẩu đơn thuần bằng SHA-256 cho hệ thống thật.
- Với hệ thống thật, nên dùng thuật toán chuyên dụng cho mật khẩu như Argon2id, bcrypt hoặc scrypt.
- Salt không cần giữ bí mật, nhưng phải khác nhau cho từng người dùng hoặc từng lần đăng ký.
- Nếu tham khảo mã, tài liệu, công cụ hoặc AI, phải ghi nguồn rõ ràng.
- Khi cộng tác nhóm, cần trung thực học thuật và mô tả đúng phần việc của mình.

## 9. Checklist nộp bài

Trước khi nộp, sinh viên cần có:

- `sha_procedure.cpp`, `structure.h`, `sha256_lib.h`
- `file_integrity.cpp` kiểm tra được file bị thay đổi
- `password_hash.cpp` kiểm tra được mật khẩu đúng/sai
- `salted_password_hash.cpp` chứng minh cùng mật khẩu nhưng salt khác nhau tạo hash khác nhau
- `README.md` mô tả rõ cách chạy, input, output, padding
- `report-1page.md` đã hoàn thiện
- `tests/` có ít nhất 5 test
- có negative test cho `tamper` và `wrong password`
- `logs/` có ít nhất 1 file minh chứng thật
- không còn placeholder dành cho sinh viên trong README/report/tests

## 10. Lưu ý kỹ thuật

Bản code này phục vụ mục tiêu học thuật để sinh viên quan sát các bước cơ bản của SHA-256:

- khởi tạo `H0_INITIAL`
- sinh lịch thông điệp `W[0..63]`
- chạy 64 vòng nén với `Ch`, `Maj`, `Sigma0`, `Sigma1`, `sigma0`, `sigma1`
- cập nhật trạng thái băm trung gian
- chuyển kết quả 8 word 32-bit thành chuỗi hexa 256-bit

Một số điểm sinh viên có thể cải tiến:

- tách giao diện dòng lệnh đẹp hơn
- thêm unit test bằng framework C++
- thêm chế độ đọc nhiều file cùng lúc
- lưu thông tin hash file theo định dạng manifest
- thêm benchmark thời gian băm file lớn
- phân tích vì sao SHA-256 không phù hợp để lưu mật khẩu trong hệ thống thật nếu không có cơ chế làm chậm/brute-force resistant
