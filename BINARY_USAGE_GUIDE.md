# Binary Usage Guide - PK Compress

## 📍 Binary Locations หลัง Build

หลังจาก build แล้ว binary จะอยู่ใน `src-tauri/target/` โดยแบ่งตาม architecture:

```
src-tauri/target/
├── debug/
│   └── pk-compress              # Debug build (23 MB, ไม่ optimize)
├── aarch64-apple-darwin/
│   └── release/
│       └── pk-compress          # ARM64/M1/M2/M3 (3.0 MB) ⭐
└── x86_64-apple-darwin/
    └── release/
        └── pk-compress          # Intel Mac (3.3 MB)
```

## 🎯 สำหรับ Mac M2 (ARM64)

**✅ ใช่แล้ว!** บน M2 ใช้ binary นี้:
```
src-tauri/target/aarch64-apple-darwin/release/pk-compress
```

## 🚀 วิธีใช้งาน

### วิธีที่ 1: รันจาก Command Line (แนะนำ)

```bash
# รันโดยตรง
./src-tauri/target/aarch64-apple-darwin/release/pk-compress

# หรือสร้าง symlink เพื่อใช้งานง่าย
ln -s src-tauri/target/aarch64-apple-darwin/release/pk-compress pk-compress
./pk-compress
```

หน้าต่าง GUI จะเปิดขึ้นมาพร้อม UI ที่สวยงาม 🎨

### วิธีที่ 2: Double-click (macOS Finder)

```bash
# เปิด Finder ไปที่ folder
open src-tauri/target/aarch64-apple-darwin/release/

# จากนั้น double-click ที่ไฟล์ pk-compress
```

**⚠️ หมายเหตุ:** ครั้งแรกอาจมี security warning เพราะ app ไม่ได้ signed
- กด "Cancel"
- เปิด **System Settings → Privacy & Security**
- คลิก **"Open Anyway"**

### วิธีที่ 3: สร้าง .app Bundle (สวยงามกว่า)

```bash
# Build แบบ bundle
cd src-tauri
cargo tauri build --target aarch64-apple-darwin

# หรือใช้ build script
cd ..
./build.sh macos
```

App bundle จะอยู่ที่:
```
src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app
```

คุณสามารถ:
- Double-click เพื่อเปิด
- ลากไปไว้ใน Applications folder
- สร้าง .dmg installer

### วิธีที่ 4: ติดตั้งเข้า Applications (แนะนำสำหรับใช้งานประจำ)

```bash
# คัดลอกไปยัง Applications
cp -r "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app" /Applications/

# หรือสร้าง symlink
ln -s "$(pwd)/src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app" /Applications/
```

จากนั้นเปิดจาก Spotlight (Cmd + Space) แล้วพิมพ์ "PK Compress"

## 📦 ทำไมมีหลาย Folder?

| Folder | ความหมาย | ขนาด | ใช้เมื่อ |
|--------|----------|------|----------|
| **debug/** | Development build | 23 MB | `cargo tauri dev` |
| **aarch64-apple-darwin/release/** | ARM64 (M1/M2/M3) | 3.0 MB | Mac Silicon ⭐ |
| **x86_64-apple-darwin/release/** | Intel Mac | 3.3 MB | Mac Intel |
| **universal-apple-darwin/** | Universal Binary | ~6 MB | รองรับทั้ง Intel & ARM |

### เหตุผล:

1. **Debug vs Release:**
   - Debug: ไม่ optimize, มี debug symbols (ใช้พัฒนา)
   - Release: Optimize แล้ว, ขนาดเล็ก, เร็วกว่า (ใช้จริง)

2. **Architecture แยก:**
   - ARM64: สำหรับชิป Apple Silicon (M1/M2/M3)
   - x86_64: สำหรับชิป Intel
   - Universal: รวมทั้งสอง (ใหญ่กว่า)

3. **Cross-compilation:**
   - Build บน M2 สามารถ build ได้ทั้ง ARM64 และ x86_64
   - ทำให้แจกจ่ายได้ทั้งสอง architecture

## 🔍 ตรวจสอบ Architecture

```bash
# ดู architecture ของ binary
file src-tauri/target/aarch64-apple-darwin/release/pk-compress
# Output: Mach-O 64-bit executable arm64

# ดู architecture ของเครื่องคุณ
uname -m
# Output: arm64 (M1/M2/M3) หรือ x86_64 (Intel)

# ดูขนาดไฟล์
ls -lh src-tauri/target/aarch64-apple-darwin/release/pk-compress
# Output: 3.0M
```

## 🎯 Quick Start

สำหรับ Mac M2 ของคุณ:

```bash
# 1. รันโดยตรง (ง่ายที่สุด)
./src-tauri/target/aarch64-apple-darwin/release/pk-compress

# 2. หรือ build bundle แล้วติดตั้ง
./build.sh macos
open "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app"
```

## 🚨 Troubleshooting

### "pk-compress" cannot be opened because the developer cannot be verified

**วิธีแก้:**
```bash
# ลบ quarantine attribute
xattr -d com.apple.quarantine src-tauri/target/aarch64-apple-darwin/release/pk-compress

# หรือ
xattr -cr src-tauri/target/aarch64-apple-darwin/release/pk-compress
```

### Binary ไม่มีสิทธิ์ Execute

```bash
# เพิ่มสิทธิ์
chmod +x src-tauri/target/aarch64-apple-darwin/release/pk-compress
```

### App เปิดแล้วดับทันที

```bash
# รันใน terminal เพื่อดู error
./src-tauri/target/aarch64-apple-darwin/release/pk-compress
```

## 📊 เปรียบเทียบ Build Types

| Build Type | Command | Output | ขนาด | ความเร็ว |
|------------|---------|--------|------|----------|
| **Dev** | `cargo tauri dev` | `target/debug/` | 23 MB | ช้า |
| **Release** | `cargo tauri build` | `target/release/` | 3 MB | เร็วมาก |
| **Specific Arch** | `--target aarch64-apple-darwin` | `target/aarch64-apple-darwin/` | 3 MB | เร็วมาก |
| **Bundle** | `cargo tauri build` | `bundle/macos/*.app` | 3+ MB | เร็วมาก + UI |

## 🎁 Distribution

หากต้องการแจกจ่ายให้ผู้อื่น:

1. **Single Binary:**
   ```bash
   # คัดลอก binary ไปแจก
   cp src-tauri/target/aarch64-apple-darwin/release/pk-compress ~/Desktop/
   ```

2. **.app Bundle:**
   ```bash
   # สร้าง .app bundle
   ./build.sh macos
   # ส่งโฟลเดอร์ .app ให้ผู้อื่น
   ```

3. **.dmg Installer:**
   ```bash
   # Tauri จะสร้าง .dmg อัตโนมัติเมื่อ build
   # ไฟล์จะอยู่ที่ src-tauri/target/aarch64-apple-darwin/release/bundle/dmg/
   ```

## 📝 Summary

**สำหรับ Mac M2 ของคุณ:**
- ✅ ใช้: `src-tauri/target/aarch64-apple-darwin/release/pk-compress`
- ✅ ขนาด: 3.0 MB
- ✅ Architecture: ARM64
- ✅ วิธีรัน: Double-click หรือ `./pk-compress`

**แนะนำ:**
```bash
# รันแบบง่ายๆ
./src-tauri/target/aarch64-apple-darwin/release/pk-compress

# หรือสร้าง alias
echo 'alias pk-compress="$(pwd)/src-tauri/target/aarch64-apple-darwin/release/pk-compress"' >> ~/.zshrc
source ~/.zshrc
pk-compress  # รันได้เลย!
```

---

**Created:** 2026-08-10  
**Platform:** macOS ARM64 (M1/M2/M3)  
**Binary:** PK Compress v0.1.0
