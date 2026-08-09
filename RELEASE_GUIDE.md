# Release & Distribution Guide - PK Compress

## ✅ คำตอบคำถาม 2 ข้อ

### 1. Double-click แล้วแสดงหน้า Terminal → ต้องการขึ้น GUI เลย

**คำตอบ: ✅ ได้แล้ว!**

**ปัญหา:**
- Double-click ไฟล์ `pk-compress` (binary เปล่า) → เห็น Terminal
- เพราะเป็น command-line executable

**วิธีแก้: ใช้ `.app` Bundle แทน**

```bash
# Build .app bundle
cd src-tauri
cargo tauri build --target aarch64-apple-darwin

# หรือใช้ build script
cd ..
./build.sh macos
```

**ผลลัพธ์:**
```
src-tauri/target/aarch64-apple-darwin/release/bundle/macos/
└── PK Compress.app  ← ใช้ตัวนี้! 🎯
```

**วิธีเปิด:**
```bash
# วิธีที่ 1: Double-click ใน Finder
open "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/"
# แล้ว double-click "PK Compress.app"

# วิธีที่ 2: Command line
open "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app"
```

**ผลลัพธ์:**
- ✅ เปิด GUI โดยตรง ไม่มี Terminal
- ✅ มี icon สวยงาม
- ✅ ติดตั้งเข้า Applications ได้

---

### 2. Release ไปเครื่องอื่น → Copy ไฟล์เดียวพอหรือไม่?

**คำตอบ: มี 3 ทางเลือก**

#### ✅ ทางเลือกที่ 1: Copy `.app` Bundle (แนะนำ)

**ใช่แล้ว! Copy โฟลเดอร์เดียวพอ:**

```bash
# Copy .app ทั้งโฟลเดอร์ไปเครื่องอื่น
cp -r "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app" ~/Desktop/

# ส่งให้เพื่อน zip แล้วส่ง
zip -r "PK-Compress.zip" "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app"
```

**ข้อกำหนด:**
- ✅ เครื่องต้องเป็น Mac M1/M2/M3 (ARM64)
- ✅ macOS 10.15 ขึ้นไป
- ✅ ไม่ต้องติดตั้งอะไรเพิ่ม (self-contained)

**ทำไม .app พอ?**
- มี binary, icons, frontend files (HTML/CSS/JS), และ frameworks ทั้งหมดอยู่ในนั้นแล้ว
- Tauri bundle ทำให้เป็น self-contained app

#### 📦 ทางเลือกที่ 2: แจก .dmg Installer (สวยงามที่สุด)

```bash
# สร้าง .dmg
cd src-tauri
cargo tauri build --target aarch64-apple-darwin

# .dmg จะอยู่ที่
# src-tauri/target/aarch64-apple-darwin/release/bundle/dmg/PK Compress_0.1.0_aarch64.dmg
```

**แจกจ่ายแบบมืออาชีพ:**
```bash
# ส่ง .dmg ให้ผู้ใช้
# พวกเขาแค่:
1. Double-click .dmg
2. Drag app ไป Applications folder
3. เสร็จ!
```

#### 🔧 ทางเลือกที่ 3: Copy Binary เปล่า (ไม่แนะนำ)

```bash
# Copy binary เดียว
cp src-tauri/target/aarch64-apple-darwin/release/pk-compress ~/Desktop/

# ส่งให้คนอื่น
```

**ปัญหา:**
- ❌ เปิดแล้วเห็น Terminal
- ❌ ไม่มี icon
- ❌ ต้องใช้ command line
- ✅ แต่ใช้งานได้ถ้ารู้วิธี

---

## 📋 สรุปการ Release

### สำหรับ Mac M2 (ARM64)

| วิธี | ไฟล์ที่ส่ง | ขนาด | ความเหมาะสม |
|------|----------|------|-------------|
| **.app Bundle** | `PK Compress.app` | 3.0 MB | ⭐⭐⭐⭐⭐ แนะนำ |
| **.dmg Installer** | `PK Compress_0.1.0_aarch64.dmg` | ~27 MB | ⭐⭐⭐⭐ มืออาชีพ |
| **Binary เปล่า** | `pk-compress` | 3.0 MB | ⭐⭐ สำหรับคนเทค |

### ขั้นตอน Release แนะนำ

#### 1. Build App Bundle

```bash
./build.sh macos

# หรือ
cd src-tauri && cargo tauri build --target aarch64-apple-darwin
```

#### 2. หา .app Bundle

```bash
# .app อยู่ที่
src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app
```

#### 3. ทดสอบก่อนแจก

```bash
# ทดสอบเปิด
open "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app"

# เช็คขนาด
du -sh "src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app"
# Output: 3.0M
```

#### 4. Zip และส่ง

```bash
# สร้าง zip เพื่อแจก
cd src-tauri/target/aarch64-apple-darwin/release/bundle/macos/
zip -r ~/Desktop/PK-Compress-v0.1.0-arm64.zip "PK Compress.app"

# หรือสร้าง .dmg (มีไฟล์อยู่แล้ว)
cp ../dmg/PK\ Compress_0.1.0_aarch64.dmg ~/Desktop/
```

---

## 🚨 สิ่งที่ต้องระวัง

### 1. Architecture ต้องตรง

| เครื่องผู้รับ | ต้องใช้ Binary |
|--------------|----------------|
| Mac M1/M2/M3 | `aarch64-apple-darwin` ✅ |
| Mac Intel | `x86_64-apple-darwin` |
| Windows | `x86_64-pc-windows-msvc` |
| Linux | `x86_64-unknown-linux-gnu` |

**Cross-compilation:**
```bash
# Build สำหรับ Intel Mac บน M2
rustup target add x86_64-apple-darwin
cargo tauri build --target x86_64-apple-darwin

# Build Universal (รองรับทั้ง Intel & ARM)
cargo tauri build --target universal-apple-darwin
```

### 2. macOS Security (Gatekeeper)

**ครั้งแรกเปิด จะมี Warning:**
```
"PK Compress" cannot be opened because the developer cannot be verified.
```

**วิธีแก้ (ผู้ใช้):**
1. ไปที่ **System Settings → Privacy & Security**
2. คลิก **"Open Anyway"**

**หรือใช้ Terminal:**
```bash
# ลบ quarantine attribute
xattr -d com.apple.quarantine "PK Compress.app"
```

**แก้ไขถาวร (Developer):**
- ต้องมี Apple Developer Account ($99/year)
- Code signing certificate
- Notarization

### 3. Dependencies (ไม่ต้องกังวล)

**ตรวจสอบ:**
```bash
# ดู dependencies ของ .app
otool -L "PK Compress.app/Contents/MacOS/pk-compress"
```

**ผลลัพธ์:**
- ✅ ใช้แค่ System frameworks ของ macOS
- ✅ ไม่มี external dependencies
- ✅ Self-contained (ส่งไปเครื่องอื่นใช้งานได้เลย)

---

## 📦 โครงสร้างภายใน .app Bundle

```
PK Compress.app/
├── Contents/
│   ├── MacOS/
│   │   └── pk-compress          # Binary (3 MB)
│   ├── Resources/
│   │   ├── icon.icns            # App icon
│   │   ├── index.html           # Frontend
│   │   ├── styles.css
│   │   └── app.js
│   ├── Frameworks/              # Tauri frameworks (if any)
│   └── Info.plist               # App metadata
```

**ทำไมใหญ่กว่า binary เปล่า?**
- Binary เปล่า: 3.0 MB
- .app bundle: 3.0 MB (เท่ากัน!)
- เพราะ frontend files (HTML/CSS/JS) เล็กมาก

---

## 🎯 Quick Guide - Release ใน 5 นาที

### สำหรับ Mac M2

```bash
# 1. Build
./build.sh macos

# 2. หา .app
cd src-tauri/target/aarch64-apple-darwin/release/bundle/macos/

# 3. ทดสอบ
open "PK Compress.app"

# 4. Zip
zip -r ~/Desktop/PK-Compress.zip "PK Compress.app"

# 5. แจก!
# ส่งไฟล์ ~/Desktop/PK-Compress.zip ให้ผู้อื่น
```

### ผู้รับทำอย่างไร?

```bash
# 1. Unzip
unzip PK-Compress.zip

# 2. Copy ไป Applications (optional)
cp -r "PK Compress.app" /Applications/

# 3. เปิด
open "PK Compress.app"

# หรือ double-click ใน Finder
```

---

## 💡 Pro Tips

### 1. สร้าง Universal Binary

รองรับทั้ง M1/M2/M3 และ Intel:

```bash
cargo tauri build --target universal-apple-darwin
```

ผลลัพธ์:
- ขนาดใหญ่ขึ้น (~6 MB)
- ใช้ได้ทุกเครื่อง Mac

### 2. แจก .dmg แบบมืออาชีพ

```bash
# .dmg มีอยู่แล้วหลัง build
ls src-tauri/target/aarch64-apple-darwin/release/bundle/dmg/

# ใช้ custom background, icon layout
# แก้ไขได้ใน tauri.conf.json
```

### 3. GitHub Releases

```bash
# Tag version
git tag v0.1.0
git push origin v0.1.0

# Upload .dmg หรือ .app.zip ไปที่ GitHub Releases
```

---

## ✅ Checklist ก่อน Release

- [ ] Build สำเร็จ (.app bundle)
- [ ] ทดสอบเปิด app โดยไม่มี Terminal
- [ ] ทดสอบ compress/decompress ทำงานได้
- [ ] เช็คขนาดไฟล์ (~3 MB)
- [ ] Zip สำหรับแจกจ่าย
- [ ] เขียน README/คู่มือการใช้
- [ ] ทดสอบบนเครื่องอื่น (ถ้าได้)
- [ ] อัพโหลดไป GitHub Releases

---

## 📞 สรุป

### คำตอบคำถาม 2 ข้อ:

1. **Double-click แล้วขึ้น GUI ได้ไหม?**
   - ✅ ได้! ใช้ `.app` bundle แทน binary เปล่า
   - Location: `src-tauri/target/aarch64-apple-darwin/release/bundle/macos/PK Compress.app`
   - Double-click แล้วขึ้น GUI เลย ไม่มี Terminal

2. **Release ไปเครื่องอื่น copy file เดียวพอไหม?**
   - ✅ พอ! Copy โฟลเดอร์ `PK Compress.app` ไปเลย
   - ✅ Self-contained ไม่ต้องติดตั้งอะไรเพิ่ม
   - ✅ ใช้ได้บน Mac M1/M2/M3 เลย
   - ⚠️ เครื่องต้องเป็น ARM64 (ถ้า build aarch64)

### วิธี Release แนะนำ:

```bash
# Build
./build.sh macos

# Zip
cd src-tauri/target/aarch64-apple-darwin/release/bundle/macos/
zip -r ~/Desktop/PK-Compress-v0.1.0-arm64.zip "PK Compress.app"

# แจก!
```

---

**Created:** 2026-08-10  
**Version:** 0.1.0  
**Platform:** macOS ARM64  
**Size:** 3.0 MB
