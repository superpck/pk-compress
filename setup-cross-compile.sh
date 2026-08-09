#!/bin/bash

# Setup script for cross-compilation toolchains on macOS
# This script installs the necessary tools to build for Windows and Linux from macOS

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo -e "${BLUE}=== Cross-Compilation Setup for macOS ===${NC}"
echo ""

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    print_warning "Homebrew is not installed"
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_success "Homebrew is already installed"
fi

echo ""
print_info "Installing cross-compilation toolchains..."
echo ""

# Install Windows cross-compilation tools
print_info "1. Installing Windows (mingw-w64) toolchain..."
if brew list mingw-w64 >/dev/null 2>&1; then
    print_success "mingw-w64 is already installed"
else
    brew install mingw-w64
    print_success "mingw-w64 installed"
fi

# Add Rust targets
print_info "2. Adding Rust targets..."

print_info "   Adding x86_64-pc-windows-gnu..."
rustup target add x86_64-pc-windows-gnu

print_info "   Adding x86_64-unknown-linux-gnu..."
rustup target add x86_64-unknown-linux-gnu

print_info "   Adding aarch64-apple-darwin..."
rustup target add aarch64-apple-darwin

print_info "   Adding x86_64-apple-darwin..."
rustup target add x86_64-apple-darwin

print_success "Rust targets added"

# Install Linux cross-compilation tools (optional)
echo ""
print_warning "Linux cross-compilation from macOS is experimental"
print_info "3. Installing Linux toolchain (optional)..."
read -p "Install Linux cross-compilation toolchain? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew tap messense/macos-cross-toolchains
    brew install x86_64-unknown-linux-gnu
    print_success "Linux toolchain installed"
else
    print_info "Skipping Linux toolchain"
fi

# Create cargo config for cross-compilation
echo ""
print_info "4. Creating Cargo configuration..."

mkdir -p src-tauri/.cargo

cat > src-tauri/.cargo/config.toml << 'EOF'
# Cross-compilation configuration for Tauri app

[target.x86_64-pc-windows-gnu]
linker = "x86_64-w64-mingw32-gcc"
ar = "x86_64-w64-mingw32-ar"

[target.x86_64-unknown-linux-gnu]
linker = "x86_64-linux-gnu-gcc"

[target.aarch64-apple-darwin]
rustflags = ["-C", "link-arg=-undefined", "-C", "link-arg=dynamic_lookup"]

[target.x86_64-apple-darwin]
rustflags = ["-C", "link-arg=-undefined", "-C", "link-arg=dynamic_lookup"]
EOF

print_success "Cargo configuration created"

# Summary
echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "Installed targets:"
rustup target list | grep installed
echo ""
echo "You can now run:"
echo "  ./build.sh macos     # Build for macOS"
echo "  ./build.sh windows   # Build for Windows"
echo "  ./build.sh linux     # Build for Linux (if toolchain installed)"
echo "  ./build.sh all       # Build for all platforms"
echo ""
print_warning "Note: Cross-compilation has limitations. For best results:"
print_info "  - macOS builds should be done on macOS"
print_info "  - Windows builds should be done on Windows or with Wine"
print_info "  - Linux builds should be done on Linux or with Docker"
