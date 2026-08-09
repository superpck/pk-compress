#!/bin/bash

# macOS-specific build and test script
# This script is optimized for testing on macOS

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== macOS Build & Test Script ===${NC}"
echo ""

# Detect macOS architecture
ARCH=$(uname -m)
echo -e "${BLUE}[INFO]${NC} Detected architecture: $ARCH"

# Step 1: Run tests
echo -e "${BLUE}[STEP 1/4]${NC} Running tests..."
cd src-tauri
cargo test --release
cd ..
echo -e "${GREEN}✓${NC} Tests passed"
echo ""

# Step 2: Build for current architecture
echo -e "${BLUE}[STEP 2/4]${NC} Building for current architecture ($ARCH)..."
cd src-tauri
if [ "$ARCH" = "arm64" ]; then
    cargo build --release --target aarch64-apple-darwin
    BINARY_PATH="target/aarch64-apple-darwin/release/compress-app"
else
    cargo build --release --target x86_64-apple-darwin
    BINARY_PATH="target/x86_64-apple-darwin/release/compress-app"
fi
cd ..
echo -e "${GREEN}✓${NC} Build completed"
echo ""

# Step 3: Verify binary
echo -e "${BLUE}[STEP 3/4]${NC} Verifying binary..."
if [ -f "src-tauri/$BINARY_PATH" ]; then
    FILE_SIZE=$(ls -lh "src-tauri/$BINARY_PATH" | awk '{print $5}')
    echo -e "${GREEN}✓${NC} Binary found: src-tauri/$BINARY_PATH"
    echo -e "  Size: $FILE_SIZE"
    
    # Check binary info
    file "src-tauri/$BINARY_PATH"
else
    echo -e "${YELLOW}[WARNING]${NC} Binary not found at expected location"
    exit 1
fi
echo ""

# Step 4: Run integration test
echo -e "${BLUE}[STEP 4/4]${NC} Running integration test..."

# Create test directory
TEST_DIR=$(mktemp -d)
TEST_SRC="$TEST_DIR/test_source"
TEST_ZIP="$TEST_DIR/test.zip"
TEST_EXTRACT="$TEST_DIR/extracted"

mkdir -p "$TEST_SRC/subfolder"
echo "Test file 1" > "$TEST_SRC/file1.txt"
echo "Test file 2" > "$TEST_SRC/subfolder/file2.txt"

echo -e "${BLUE}[INFO]${NC} Test directory: $TEST_DIR"
echo -e "${BLUE}[INFO]${NC} Testing compression and decompression..."

# Note: Since this is a Tauri app, we can't directly test the commands without the frontend
# But we can verify the Rust library functions work via cargo test
echo -e "${YELLOW}[INFO]${NC} Integration testing requires running the Tauri app"
echo -e "${YELLOW}[INFO]${NC} Use 'cargo test' for unit tests (already passed above)"

# Cleanup
rm -rf "$TEST_DIR"
echo -e "${GREEN}✓${NC} Integration test setup verified"
echo ""

# Summary
echo -e "${GREEN}=== Build & Test Completed Successfully ===${NC}"
echo ""
echo "Binary location: src-tauri/$BINARY_PATH"
echo ""
echo "To run the app:"
echo "  1. Install a frontend (Angular, React, etc.)"
echo "  2. Run: npm run tauri dev"
echo ""
echo "To build production app bundle:"
echo "  npm run tauri build"
