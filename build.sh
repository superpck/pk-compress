#!/bin/bash

# File Compression App - Build Script
# Cross-platform build script for macOS, Windows, and Linux

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command_exists cargo; then
        print_error "Rust/Cargo is not installed. Please install from https://rustup.rs/"
        exit 1
    fi
    
    if ! command_exists npm; then
        print_error "npm is not installed. Please install Node.js from https://nodejs.org/"
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Function to build for macOS
build_macos() {
    print_info "Building for macOS..."
    
    cd src-tauri
    
    # Build for macOS (Apple Silicon - aarch64)
    print_info "Building for macOS ARM64 (Apple Silicon)..."
    cargo build --release --target aarch64-apple-darwin
    
    # Build for macOS (Intel - x86_64)
    print_info "Building for macOS x86_64 (Intel)..."
    cargo build --release --target x86_64-apple-darwin
    
    cd ..
    
    print_success "macOS build completed"
    print_info "ARM64 binary: src-tauri/target/aarch64-apple-darwin/release/compress-app"
    print_info "x86_64 binary: src-tauri/target/x86_64-apple-darwin/release/compress-app"
}

# Function to build for Windows (requires cross-compilation setup)
build_windows() {
    print_info "Building for Windows..."
    
    # Check if Windows target is installed
    if ! rustup target list | grep -q "x86_64-pc-windows-gnu (installed)\|x86_64-pc-windows-msvc (installed)"; then
        print_warning "Windows target not installed. Installing x86_64-pc-windows-gnu..."
        rustup target add x86_64-pc-windows-gnu
    fi
    
    cd src-tauri
    
    # Note: Cross-compiling to Windows from macOS requires mingw-w64
    if command_exists x86_64-w64-mingw32-gcc; then
        print_info "Building for Windows x86_64..."
        cargo build --release --target x86_64-pc-windows-gnu
        print_success "Windows build completed"
        print_info "Binary: src-tauri/target/x86_64-pc-windows-gnu/release/compress-app.exe"
    else
        print_error "Windows cross-compilation toolchain not found"
        print_info "To install on macOS: brew install mingw-w64"
        print_info "Skipping Windows build..."
    fi
    
    cd ..
}

# Function to build for Linux (requires cross-compilation setup)
build_linux() {
    print_info "Building for Linux..."
    
    # Check if Linux target is installed
    if ! rustup target list | grep -q "x86_64-unknown-linux-gnu (installed)"; then
        print_warning "Linux target not installed. Installing x86_64-unknown-linux-gnu..."
        rustup target add x86_64-unknown-linux-gnu
    fi
    
    cd src-tauri
    
    # Note: Cross-compiling to Linux from macOS requires cross toolchain
    if command_exists x86_64-linux-gnu-gcc; then
        print_info "Building for Linux x86_64..."
        cargo build --release --target x86_64-unknown-linux-gnu
        print_success "Linux build completed"
        print_info "Binary: src-tauri/target/x86_64-unknown-linux-gnu/release/compress-app"
    else
        print_error "Linux cross-compilation toolchain not found"
        print_info "To install on macOS: brew tap messense/macos-cross-toolchains"
        print_info "                     brew install x86_64-unknown-linux-gnu"
        print_info "Skipping Linux build..."
    fi
    
    cd ..
}

# Function to run tests
run_tests() {
    print_info "Running Rust tests..."
    
    cd src-tauri
    cargo test --release
    cd ..
    
    print_success "All tests passed"
}

# Function to clean build artifacts
clean_build() {
    print_info "Cleaning build artifacts..."
    
    cd src-tauri
    cargo clean
    cd ..
    
    print_success "Build artifacts cleaned"
}

# Function to create distribution packages
create_dist() {
    print_info "Creating distribution packages..."
    
    DIST_DIR="dist"
    mkdir -p "$DIST_DIR"
    
    # Copy binaries to dist directory
    if [ -f "src-tauri/target/aarch64-apple-darwin/release/compress-app" ]; then
        cp "src-tauri/target/aarch64-apple-darwin/release/compress-app" "$DIST_DIR/compress-app-macos-arm64"
        print_success "Copied macOS ARM64 binary to $DIST_DIR"
    fi
    
    if [ -f "src-tauri/target/x86_64-apple-darwin/release/compress-app" ]; then
        cp "src-tauri/target/x86_64-apple-darwin/release/compress-app" "$DIST_DIR/compress-app-macos-x86_64"
        print_success "Copied macOS x86_64 binary to $DIST_DIR"
    fi
    
    if [ -f "src-tauri/target/x86_64-pc-windows-gnu/release/compress-app.exe" ]; then
        cp "src-tauri/target/x86_64-pc-windows-gnu/release/compress-app.exe" "$DIST_DIR/compress-app-windows-x86_64.exe"
        print_success "Copied Windows binary to $DIST_DIR"
    fi
    
    if [ -f "src-tauri/target/x86_64-unknown-linux-gnu/release/compress-app" ]; then
        cp "src-tauri/target/x86_64-unknown-linux-gnu/release/compress-app" "$DIST_DIR/compress-app-linux-x86_64"
        print_success "Copied Linux binary to $DIST_DIR"
    fi
    
    print_success "Distribution packages created in $DIST_DIR/"
}

# Main function
main() {
    print_info "=== File Compression App Build Script ==="
    echo ""
    
    # Parse command line arguments
    TARGET="${1:-all}"
    
    case "$TARGET" in
        macos)
            check_prerequisites
            build_macos
            create_dist
            ;;
        windows)
            check_prerequisites
            build_windows
            create_dist
            ;;
        linux)
            check_prerequisites
            build_linux
            create_dist
            ;;
        test)
            check_prerequisites
            run_tests
            ;;
        clean)
            clean_build
            ;;
        all)
            check_prerequisites
            run_tests
            build_macos
            build_windows
            build_linux
            create_dist
            ;;
        *)
            echo "Usage: $0 [macos|windows|linux|test|clean|all]"
            echo ""
            echo "Commands:"
            echo "  macos    - Build for macOS (ARM64 and x86_64)"
            echo "  windows  - Build for Windows (x86_64)"
            echo "  linux    - Build for Linux (x86_64)"
            echo "  test     - Run tests"
            echo "  clean    - Clean build artifacts"
            echo "  all      - Build for all platforms (default)"
            echo ""
            echo "Examples:"
            echo "  $0           # Build for all platforms"
            echo "  $0 macos     # Build for macOS only"
            echo "  $0 test      # Run tests only"
            exit 1
            ;;
    esac
    
    echo ""
    print_success "=== Build completed successfully ==="
}

# Run main function
main "$@"
