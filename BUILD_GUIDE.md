# Build Scripts Documentation

คู่มือการใช้งาน build scripts สำหรับ File Compression Application

## 📋 Overview

มี 3 build scripts หลัก:

1. **build.sh** - Main build script สำหรับ build ทุก platform
2. **build-macos-test.sh** - Script เฉพาะสำหรับ build และ test บน macOS
3. **setup-cross-compile.sh** - Script สำหรับติดตั้ง cross-compilation tools

## 🚀 Quick Start (macOS)

### การ test บน macOS (แนะนำ)

```bash
# Build และ test บน macOS (รวดเร็วที่สุด)
./build-macos-test.sh
```

Script นี้จะ:
- ✅ รัน tests ทั้งหมด (6 tests)
- ✅ Build สำหรับ architecture ปัจจุบัน (ARM64 หรือ x86_64)
- ✅ Verify binary ที่ build แล้ว
- ✅ แสดงข้อมูล size และ location ของ binary

### การ build แยก platform

```bash
# Build เฉพาะ macOS
./build.sh macos

# Build เฉพาะ Windows (ต้องติดตั้ง toolchain ก่อน)
./build.sh windows

# Build เฉพาะ Linux (ต้องติดตั้ง toolchain ก่อน)
./build.sh linux

# Build ทุก platform
./build.sh all

# รัน tests เท่านั้น
./build.sh test

# ลบ build artifacts
./build.sh clean
```

## 🛠 Setup Cross-Compilation (สำหรับ Windows & Linux)

ถ้าต้องการ build สำหรับ Windows หรือ Linux จาก macOS ต้องติดตั้ง toolchains ก่อน:

```bash
./setup-cross-compile.sh
```

Script นี้จะ:
1. ติดตั้ง Homebrew (ถ้ายังไม่มี)
2. ติดตั้ง mingw-w64 สำหรับ Windows builds
3. เพิ่ม Rust targets สำหรับ cross-compilation
4. ติดตั้ง Linux toolchain (optional)
5. สร้าง Cargo configuration สำหรับ cross-compilation

## 📦 Build Outputs

### Binary Locations

หลังจาก build เสร็จ binaries จะอยู่ที่:

```
src-tauri/target/
├── aarch64-apple-darwin/release/compress-app         # macOS ARM64
├── x86_64-apple-darwin/release/compress-app          # macOS Intel
├── x86_64-pc-windows-gnu/release/compress-app.exe    # Windows
└── x86_64-unknown-linux-gnu/release/compress-app     # Linux
```

### Distribution Packages

Build script จะ copy binaries ไปที่ `dist/` folder:

```
dist/
├── compress-app-macos-arm64
├── compress-app-macos-x86_64
├── compress-app-windows-x86_64.exe
└── compress-app-linux-x86_64
```

## ✅ Test Results

การรัน tests จะแสดงผลลัพธ์:

```
running 6 tests
test rar_placeholder::tests::test_decompress_rar_not_implemented ... ok
test decompress_zip::tests::test_decompress_nonexistent_file ... ok
test compress_zip::tests::test_compress_nonexistent_directory ... ok
test compress_zip::tests::test_compress_folder_with_password ... ok
test decompress_zip::tests::test_decompress_with_wrong_password ... ok
test decompress_zip::tests::test_decompress_zip_with_password ... ok

test result: ok. 6 passed; 0 failed; 0 ignored
```

## 🎯 Targets Support

### macOS (Native)

| Target | Support | Command |
|--------|---------|---------|
| ARM64 (Apple Silicon) | ✅ Full | `./build.sh macos` |
| x86_64 (Intel) | ✅ Full | `./build.sh macos` |

### Windows (Cross-compile)

| Target | Support | Requirements |
|--------|---------|--------------|
| x86_64 | ⚠️ Limited | mingw-w64 toolchain |

**Note**: Cross-compiling to Windows from macOS มีข้อจำกัด แนะนำให้ build บน Windows จริงสำหรับ production

### Linux (Cross-compile)

| Target | Support | Requirements |
|--------|---------|--------------|
| x86_64 | ⚠️ Experimental | Linux cross toolchain |

**Note**: แนะนำให้ build บน Linux หรือใช้ Docker สำหรับ production builds

## 🔧 Troubleshooting

### ปัญหา: "Windows target not installed"

**แก้ไข**:
```bash
rustup target add x86_64-pc-windows-gnu
```

### ปัญหา: "x86_64-w64-mingw32-gcc not found"

**แก้ไข**:
```bash
brew install mingw-w64
```

### ปัญหา: "Linux toolchain not found"

**แก้ไข**:
```bash
brew tap messense/macos-cross-toolchains
brew install x86_64-unknown-linux-gnu
```

### ปัญหา: Build ล้มเหลวด้วย linking errors

**แก้ไข**:
1. ตรวจสอบว่า `Cargo.toml` ใช้ Pure Rust features เท่านั้น
2. ลบ `target/` directory และ build ใหม่:
   ```bash
   ./build.sh clean
   ./build.sh macos
   ```

## 📊 Build Performance

| Platform | Build Time (Release) | Binary Size |
|----------|---------------------|-------------|
| macOS ARM64 | ~2-3 min | ~5-8 MB |
| macOS x86_64 | ~2-3 min | ~5-8 MB |
| Windows | ~3-5 min | ~6-10 MB |
| Linux | ~3-5 min | ~5-8 MB |

*เวลาที่แสดงเป็นค่าประมาณบน MacBook Pro M1/M2*

## 🎨 Script Features

### build-macos-test.sh
- ✅ Colored output (สีสันสวยงาม)
- ✅ Auto-detect architecture (ARM64/x86_64)
- ✅ Step-by-step progress indicator
- ✅ Binary verification
- ✅ Size reporting

### build.sh
- ✅ Multi-platform support
- ✅ Prerequisite checking
- ✅ Error handling
- ✅ Distribution package creation
- ✅ Test execution

### setup-cross-compile.sh
- ✅ Interactive setup
- ✅ Toolchain installation
- ✅ Cargo configuration generation
- ✅ Target management

## 🚀 Production Build

สำหรับ production ควรใช้คำสั่ง:

```bash
# Build optimized binary สำหรับ platform ปัจจุบัน
./build-macos-test.sh

# หรือ build แยก release profile
cd src-tauri
cargo build --release --target aarch64-apple-darwin
```

Binary ที่ได้จะมีการ optimize:
- ✅ Strip symbols
- ✅ LTO (Link Time Optimization)
- ✅ Size optimization (`opt-level = "s"`)

## 📝 Examples

### Example 1: Development Testing

```bash
# รัน tests เท่านั้น
./build.sh test
```

### Example 2: Build for Current macOS

```bash
# Build และ test สำหรับ macOS
./build-macos-test.sh
```

### Example 3: Build for Distribution

```bash
# Setup cross-compile (ครั้งแรกเท่านั้น)
./setup-cross-compile.sh

# Build ทุก platform
./build.sh all

# Binaries จะอยู่ใน dist/ folder
ls -lh dist/
```

### Example 4: Clean Build

```bash
# ลบ build artifacts
./build.sh clean

# Build ใหม่
./build.sh macos
```

## 🔗 Related Documentation

- [README.md](README.md) - Main project documentation
- [AGENTS.md](AGENTS.md) - AI agent instructions
- [request.txt](request.txt) - Original requirements

## 💡 Tips

1. **สำหรับ development**: ใช้ `./build-macos-test.sh` เพราะรวดเร็วและครบถ้วน
2. **สำหรับ CI/CD**: ใช้ `./build.sh all` เพื่อ build ทุก platform
3. **สำหรับ production**: Build บน native platform แต่ละตัวเพื่อผลลัพธ์ที่ดีที่สุด
4. **ก่อน commit**: รัน `./build.sh test` เสมอเพื่อตรวจสอบว่า code ใหม่ไม่ทำให้ tests fail

## ⚠️ Limitations

1. **Cross-compilation ไม่สมบูรณ์**: บาง features อาจไม่ทำงานเมื่อ cross-compile
2. **Tauri specifics**: บาง Tauri features ต้อง build บน platform เป้าหมาย
3. **Native dependencies**: ถ้ามี native dependencies ใน future ต้อง build บน platform นั้นๆ

## 📞 Support

หากมีปัญหา:
1. ตรวจสอบ error messages ใน console
2. รัน `./build.sh clean` และลอง build ใหม่
3. ตรวจสอบว่า prerequisites ครบถ้วน (Rust, npm, toolchains)
4. อ่าน Troubleshooting section ด้านบน
