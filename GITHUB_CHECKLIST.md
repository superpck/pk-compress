# GitHub Upload Checklist

คู่มือตรวจสอบก่อนอัพโหลด **PK Compress** ขึ้น GitHub

## ✅ สิ่งที่ควรตรวจสอบก่อน Push

### 1. License & Legal ⚖️

#### ✅ สิ่งที่ทำแล้ว
- [x] **LICENSE file** - MIT License (permissive, safe for open source)
- [x] **THIRD_PARTY_LICENSES.md** - รายการ dependencies และ licenses
- [x] **Copyright notices** - ระบุ copyright holder (PK) ในไฟล์ LICENSE
- [x] **.gitignore** - ป้องกันไฟล์ที่ไม่ควร commit

#### ⚠️ สิ่งที่ต้องระวัง

**RAR Support:**
- ✅ ปัจจุบันเป็น **placeholder เท่านั้น** ไม่มี implementation จริง
- ⚠️ หากจะเพิ่ม RAR support ในอนาคต ต้องระวัง:
  - UnRAR license มีข้อจำกัดการใช้งาน
  - ไม่สามารถใช้ UnRAR source code ในโปรเจกต์ open source ได้โดยตรง
  - ทางเลือกที่ปลอดภัย:
    1. ใช้ command-line tools ภายนอก (ผู้ใช้ติดตั้งเอง)
    2. ให้ผู้ใช้จัดการ RAR extraction เอง
    3. ระบุชัดเจนว่าต้องการ external tools

**Dependencies:**
- ✅ ทุก crate ที่ใช้มี permissive licenses (MIT/Apache-2.0/Unlicense)
- ✅ ไม่มี GPL dependencies (จะทำให้โปรเจกต์ต้องเป็น GPL ด้วย)

### 2. Security & Privacy 🔒

#### ต้องเช็คก่อน Commit
- [ ] ไม่มี API keys, tokens, passwords ในโค้ด
- [ ] ไม่มี personal information ใน commit history
- [ ] `.env` files อยู่ใน `.gitignore`
- [ ] ไม่มี test credentials ใน source code

#### Recommendations
```bash
# ค้นหา secrets ที่อาจรั่วไหล
git grep -i "password\|api_key\|secret\|token" -- ':!THIRD_PARTY_LICENSES.md'

# ตรวจสอบไฟล์ใหญ่ที่ไม่ควร commit
git ls-files | xargs ls -lh | sort -k5 -h | tail -10
```

### 3. Code Quality 💻

- [x] Tests ผ่านทั้งหมด (6/6 tests)
- [ ] Documentation ครบถ้วน
- [x] Build scripts ใช้งานได้
- [x] README.md มีข้อมูลครบถ้วน

### 4. Files to Exclude 🚫

ตรวจสอบว่า `.gitignore` ครอบคลุมไฟล์เหล่านี้:
- [x] `target/` - Rust build artifacts
- [x] `dist/` - Distribution binaries
- [x] `node_modules/` - Node dependencies
- [x] `.DS_Store` - macOS metadata
- [x] `*.log` - Log files
- [x] Build outputs (`.exe`, `.dmg`, `.deb`, etc.)

### 5. Repository Setup 🔧

#### ข้อมูลที่ต้องเติมบน GitHub

**Repository Name:**
```
pk-compress
```

**Description:**
```
Cross-platform file compression tool with AES-256 encryption. Built with Tauri v2, Angular, and Rust.
```

**Topics/Tags:**
```
compression, zip, encryption, tauri, rust, angular, cross-platform, aes-256, file-compression
```

**README.md checklist:**
- [x] Badges (License, Language)
- [x] Features section
- [x] Installation instructions
- [x] API documentation
- [x] Build instructions
- [x] License information

### 6. Pre-Push Commands ⚙️

รันคำสั่งเหล่านี้ก่อน push:

```bash
# 1. Run tests
./build.sh test

# 2. Check for compilation errors
cd src-tauri && cargo check && cd ..

# 3. Format code (optional)
cd src-tauri && cargo fmt && cd ..

# 4. Run clippy for code quality (optional)
cd src-tauri && cargo clippy -- -D warnings && cd ..

# 5. Build to ensure everything works
./build.sh macos

# 6. Check git status
git status

# 7. Review changes
git diff

# 8. Check for large files
find . -type f -size +10M | grep -v target/ | grep -v node_modules/
```

### 7. Initial Commit Structure 📝

แนะนำโครงสร้าง commits:

```bash
# First commit
git init
git add LICENSE THIRD_PARTY_LICENSES.md .gitignore
git commit -m "chore: add license and legal documents"

# Second commit
git add README.md AGENTS.md BUILD_GUIDE.md BUILD_SUMMARY.md
git commit -m "docs: add project documentation"

# Third commit
git add src-tauri/ *.sh icon.svg
git commit -m "feat: initial implementation of PK Compress"

# Fourth commit
git add request.txt
git commit -m "docs: add requirements specification"
```

### 8. GitHub Repository Settings ⚙️

หลังสร้าง repository บน GitHub:

**Settings to Configure:**

1. **General:**
   - ✅ Add description
   - ✅ Add website/homepage
   - ✅ Add topics
   - ✅ Enable Issues
   - ✅ Enable Discussions (optional)

2. **Security:**
   - ⚠️ Enable Dependabot alerts
   - ⚠️ Enable security advisories
   - ✅ Consider adding SECURITY.md

3. **Pages (optional):**
   - If you want documentation site

4. **Actions (optional):**
   - Set up CI/CD for automated testing

### 9. License Compliance Summary ✅

**Your Project (PK Compress):**
- License: MIT ✅
- Copyright: PK (2026) ✅
- Commercial use: Allowed ✅
- Modification: Allowed ✅
- Distribution: Allowed ✅
- Patent grant: Not explicitly granted (MIT doesn't include patent clause)

**All Dependencies:**
| Dependency | License | Compatible? |
|------------|---------|-------------|
| zip | MIT OR Apache-2.0 | ✅ Yes |
| walkdir | Unlicense OR MIT | ✅ Yes |
| tauri | MIT OR Apache-2.0 | ✅ Yes |
| serde | MIT OR Apache-2.0 | ✅ Yes |
| tempfile | MIT OR Apache-2.0 | ✅ Yes |

**No Problematic Dependencies:**
- ❌ No GPL/LGPL (would require reciprocal licensing)
- ❌ No proprietary code
- ❌ No patent encumbered formats (RAR not implemented)

### 10. Important Files Checklist 📄

ตรวจสอบว่ามีไฟล์สำคัญเหล่านี้:

- [x] **LICENSE** - Required
- [x] **README.md** - Required
- [x] **.gitignore** - Required
- [x] **THIRD_PARTY_LICENSES.md** - Recommended
- [x] **AGENTS.md** - For AI agents
- [x] **BUILD_GUIDE.md** - For developers
- [ ] **CONTRIBUTING.md** - Recommended (optional)
- [ ] **CODE_OF_CONDUCT.md** - Recommended (optional)
- [ ] **SECURITY.md** - Recommended (optional)

### 11. Final Checklist Before Push 🚀

```bash
# ✅ Final checks
[ ] All tests pass
[ ] No sensitive data in code
[ ] .gitignore is comprehensive
[ ] LICENSE file is present
[ ] README is complete
[ ] Build scripts work
[ ] No large binaries in git (check dist/ is ignored)
[ ] Repository name matches package name
[ ] Email in git config is correct

# Ready to push!
git remote add origin https://github.com/[your-username]/pk-compress.git
git branch -M main
git push -u origin main
```

## 🎯 Quick Start Commands

```bash
# 1. Initialize git (if not done)
git init

# 2. Add all files
git add .

# 3. Review what will be committed
git status

# 4. Create initial commit
git commit -m "Initial commit: PK Compress v0.1.0"

# 5. Create repository on GitHub (do this in web browser)
# Then add remote:
git remote add origin https://github.com/[your-username]/pk-compress.git

# 6. Push to GitHub
git branch -M main
git push -u origin main
```

## ⚠️ Common Mistakes to Avoid

1. **Don't commit binaries**
   - ❌ `dist/compress-app-*`
   - ❌ `target/` directory
   - ✅ Use `.gitignore`

2. **Don't commit secrets**
   - ❌ API keys
   - ❌ Passwords
   - ❌ Private keys

3. **Don't commit large files**
   - ❌ Videos, images > 10MB
   - ❌ Database dumps
   - ✅ Use Git LFS if needed

4. **Don't forget license**
   - ❌ "All rights reserved"
   - ✅ Clear license (MIT)
   - ✅ Third-party licenses documented

## 📊 License Compatibility Matrix

```
Your Project (MIT)
    ├─ Can include: MIT, BSD, Apache-2.0, Unlicense
    ├─ Cannot include: GPL (without relicensing entire project)
    ├─ Be careful: Proprietary (like RAR)
    └─ Result: MIT (most permissive)
```

## 🔍 Post-Upload Verification

After pushing to GitHub:

1. **Check repository page:**
   - [ ] README displays correctly
   - [ ] License is detected by GitHub
   - [ ] Topics/tags are visible
   - [ ] Description is shown

2. **Test clone:**
   ```bash
   git clone https://github.com/[your-username]/pk-compress.git test-clone
   cd test-clone
   ./build.sh test
   ```

3. **Check insights:**
   - [ ] Dependency graph shows no alerts
   - [ ] License is recognized
   - [ ] No security vulnerabilities

## 📞 Need Help?

If you're unsure about:
- **License compatibility**: Check https://choosealicense.com/appendix/
- **Git basics**: https://git-scm.com/doc
- **GitHub**: https://docs.github.com/

---

**Status**: ✅ Ready for GitHub upload  
**Last Updated**: 2026-08-09  
**Review Required**: RAR implementation (if added in future)
