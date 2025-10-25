#!/bin/bash

# AmLang Compiler Installation Script
# Downloads and installs the latest AmLang Compiler binary

set -e

# Configuration
RELEASES_REPO="anderskjeldsen/am-lang-compiler"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION="${VERSION:-latest}"
INSTALL_TYPE="${INSTALL_TYPE:-auto}"  # auto, native, jar

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    local os arch
    
    case "$(uname -s)" in
        Linux*)
            os="linux"
            ;;
        Darwin*)
            os="macos"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            os="windows"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    
    echo "${os}-${arch}"
}

# Get latest version
get_latest_version() {
    local api_url="https://api.github.com/repos/${RELEASES_REPO}/releases/latest"
    local version
    
    if command -v curl >/dev/null 2>&1; then
        version=$(curl -s "$api_url" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
    elif command -v wget >/dev/null 2>&1; then
        version=$(wget -qO- "$api_url" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
    else
        log_error "Neither curl nor wget is available"
        exit 1
    fi
    
    if [[ -z "$version" ]]; then
        log_error "Failed to fetch latest version"
        exit 1
    fi
    
    echo "$version"
}

# Check for Java (for JAR installations)
check_java() {
    if command -v java >/dev/null 2>&1; then
        local java_version
        java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [[ "$java_version" -ge 21 ]]; then
            return 0
        else
            log_warning "Java $java_version found, but Java 21+ is required for JAR version"
            return 1
        fi
    else
        return 1
    fi
}

# Determine best installation type
determine_install_type() {
    local platform="$1"
    
    case "$INSTALL_TYPE" in
        native)
            echo "native"
            ;;
        jar)
            if check_java; then
                echo "jar"
            else
                log_error "JAR installation requested but Java 21+ not found"
                exit 1
            fi
            ;;
        auto)
            # Try native first, fall back to JAR if Java is available
            if [[ "$platform" == *"windows"* ]] || [[ "$platform" == *"arm64"* ]]; then
                # For platforms that might have cross-compilation issues, prefer JAR if Java is available
                if check_java; then
                    log_info "Java 21+ detected, preferring JAR for better compatibility"
                    echo "jar"
                else
                    echo "native"
                fi
            else
                echo "native"
            fi
            ;;
        *)
            log_error "Invalid install type: $INSTALL_TYPE"
            exit 1
            ;;
    esac
}

# Download and install
install_amlc() {
    local platform="$1"
    local version="$2"
    local install_type="$3"
    local temp_dir
    
    # Create temporary directory
    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT
    
    if [[ "$install_type" == "jar" ]]; then
        install_jar "$platform" "$version" "$temp_dir"
    else
        install_native "$platform" "$version" "$temp_dir"
    fi
}

# Install JAR version
install_jar() {
    local platform="$1"
    local version="$2"
    local temp_dir="$3"
    
    log_info "Installing JAR version of AmLang Compiler ${version}..."
    
    # Use the direct JAR download from GitHub releases
    local jar_filename="amlc-${version#v}.jar"
    local launcher_filename="amlc.sh"
    
    if [[ "$platform" == *"windows"* ]]; then
        launcher_filename="amlc.bat"
    fi
    
    # Download URLs for JAR and launcher
    local jar_url="https://github.com/${RELEASES_REPO}/releases/download/${version}/${jar_filename}"
    local launcher_url="https://github.com/${RELEASES_REPO}/releases/download/${version}/${launcher_filename}"
    
    log_info "Downloading JAR and launcher..."
    log_info "JAR URL: $jar_url"
    log_info "Launcher URL: $launcher_url"
    
    # Download JAR
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$temp_dir/$jar_filename" "$jar_url"
        curl -L -o "$temp_dir/$launcher_filename" "$launcher_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$temp_dir/$jar_filename" "$jar_url"
        wget -O "$temp_dir/$launcher_filename" "$launcher_url"
    else
        log_error "Neither curl nor wget is available"
        exit 1
    fi
    
    # Verify downloads
    if [[ ! -f "$temp_dir/$jar_filename" ]] || [[ ! -s "$temp_dir/$jar_filename" ]]; then
        log_error "JAR download failed or file is empty"
        exit 1
    fi
    
    if [[ ! -f "$temp_dir/$launcher_filename" ]] || [[ ! -s "$temp_dir/$launcher_filename" ]]; then
        log_error "Launcher download failed or file is empty"
        exit 1
    fi
    
    log_info "Installing JAR to $INSTALL_DIR..."
    
    # Create install directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating directory $INSTALL_DIR"
        sudo mkdir -p "$INSTALL_DIR"
    fi
    
    # Install JAR and launcher
    local target_jar="amlc.jar"
    local target_launcher="amlc"
    
    if [[ -w "$INSTALL_DIR" ]]; then
        cp "$temp_dir/$jar_filename" "$INSTALL_DIR/$target_jar"
        cp "$temp_dir/$launcher_filename" "$INSTALL_DIR/$target_launcher"
        chmod +x "$INSTALL_DIR/$target_launcher"
    else
        sudo cp "$temp_dir/$jar_filename" "$INSTALL_DIR/$target_jar"
        sudo cp "$temp_dir/$launcher_filename" "$INSTALL_DIR/$target_launcher"
        sudo chmod +x "$INSTALL_DIR/$target_launcher"
    fi
    
    # Update launcher script to use installed JAR name
    if [[ -w "$INSTALL_DIR" ]]; then
        sed -i "s/amlc-.*\.jar/amlc.jar/g" "$INSTALL_DIR/$target_launcher"
    else
        sudo sed -i "s/amlc-.*\.jar/amlc.jar/g" "$INSTALL_DIR/$target_launcher"
    fi
    
    log_success "AmLang Compiler (JAR) installed successfully!"
    log_info "JAR location: $INSTALL_DIR/$target_jar"
    log_info "Launcher: $INSTALL_DIR/$target_launcher"
    
    # Test installation
    if command -v "$target_launcher" >/dev/null 2>&1; then
        log_success "Installation verified: $(which $target_launcher)"
        log_info "Run 'amlc build . -bt linux-x64' in a project directory to test"
    else
        log_warning "Launcher installed but not in PATH. Add $INSTALL_DIR to your PATH:"
        echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
}

# Install native version
install_native() {
    local platform="$1"
    local version="$2"
    local temp_dir="$3"
    
    # Determine file extension and executable name based on actual releases
    local extension="tar.gz"
    local filename
    local executable="amlc"
    
    # Map platform to actual release file names
    case "$platform" in
        linux-x64)
            filename="amlc-linux-x64-${version#v}.tar.gz"
            executable="amlc-linux"
            ;;
        macos-x64)
            filename="amlc-macos-x64-${version#v}.tar.gz"
            executable="amlc-mac"
            ;;
        macos-arm64)
            filename="amlc-macos-arm64-${version#v}.tar.gz"
            executable="amlc-mac-arm64"
            ;;
        windows-x64)
            filename="amlc-windows-${version#v}.zip"
            executable="amlc-windows.exe"
            extension="zip"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
    
    log_info "Downloading AmLang Compiler ${version} for ${platform}..."
    
    # Use GitHub releases download URL
    local download_url="https://github.com/${RELEASES_REPO}/releases/download/${version}/${filename}"
    
    log_info "URL: $download_url"
    
    # Download
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$temp_dir/$filename" "$download_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$temp_dir/$filename" "$download_url"
    else
        log_error "Neither curl nor wget is available"
        exit 1
    fi
    
    # Verify download
    if [[ ! -f "$temp_dir/$filename" ]] || [[ ! -s "$temp_dir/$filename" ]]; then
        log_error "Download failed or file is empty"
        exit 1
    fi
    
    log_info "Download completed, extracting..."
    
    # Extract
    cd "$temp_dir"
    if [[ "$extension" == "zip" ]]; then
        if command -v unzip >/dev/null 2>&1; then
            unzip -q "$filename"
        else
            log_error "unzip is not available"
            exit 1
        fi
    else
        tar -xzf "$filename"
    fi
    
    # Find executable
    local binary_path
    if [[ -f "$executable" ]]; then
        binary_path="$executable"
    else
        # Try to find it in extracted contents
        binary_path=$(find . -name "amlc*" -type f -executable | head -1)
        if [[ -z "$binary_path" ]]; then
            log_error "Could not find executable in extracted archive"
            exit 1
        fi
    fi
    
    log_info "Installing to $INSTALL_DIR..."
    
    # Create install directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating directory $INSTALL_DIR"
        sudo mkdir -p "$INSTALL_DIR"
    fi
    
    # Install binary
    local target_name="amlc"
    if [[ "$platform" == *"windows"* ]]; then
        target_name="amlc.exe"
    fi
    
    if [[ -w "$INSTALL_DIR" ]]; then
        cp "$binary_path" "$INSTALL_DIR/$target_name"
        chmod +x "$INSTALL_DIR/$target_name"
    else
        sudo cp "$binary_path" "$INSTALL_DIR/$target_name"
        sudo chmod +x "$INSTALL_DIR/$target_name"
    fi
    
    log_success "AmLang Compiler (native) installed successfully!"
    log_info "Location: $INSTALL_DIR/$target_name"
    
    # Test installation
    if command -v "$target_name" >/dev/null 2>&1; then
        log_success "Installation verified: $(which $target_name)"
        log_info "Run 'amlc build . -bt linux-x64' in a project directory to test"
    else
        log_warning "Binary installed but not in PATH. Add $INSTALL_DIR to your PATH:"
        echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
}

# Show usage
usage() {
    cat << EOF
AmLang Compiler Installation Script

USAGE:
    install-amlc.sh [OPTIONS]

OPTIONS:
    -v, --version VERSION    Install specific version (default: latest)
    -d, --dir DIRECTORY      Installation directory (default: /usr/local/bin)
    -p, --platform PLATFORM Override platform detection
    -t, --type TYPE          Installation type: auto, native, jar (default: auto)
    -h, --help               Show this help message

EXAMPLES:
    # Install latest version (auto-detect best type)
    ./install-amlc.sh

    # Install specific version
    ./install-amlc.sh --version v0.6.4

    # Force JAR installation
    ./install-amlc.sh --type jar

    # Install native binary to custom directory
    ./install-amlc.sh --type native --dir ~/.local/bin

    # Install for specific platform
    ./install-amlc.sh --platform linux-arm64

INSTALLATION TYPES:
    auto     Automatically choose best type (native preferred, JAR fallback)
    native   Install native binary (fastest, no Java required)
    jar      Install JAR version (requires Java 21+, maximum compatibility)

SUPPORTED PLATFORMS:
    - linux-x64
    - linux-arm64
    - macos-x64
    - macos-arm64
    - windows-x64

ENVIRONMENT VARIABLES:
    VERSION        Version to install (e.g., v0.6.4, latest)
    INSTALL_DIR    Installation directory
    INSTALL_TYPE   Installation type (auto, native, jar)
    
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -t|--type)
            INSTALL_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    log_info "AmLang Compiler Installation Script"
    echo
    
    # Detect platform if not specified
    if [[ -z "$PLATFORM" ]]; then
        PLATFORM=$(detect_platform)
    fi
    
    # Determine installation type
    local install_type
    install_type=$(determine_install_type "$PLATFORM")
    
    log_info "Platform: $PLATFORM"
    log_info "Install type: $install_type"
    log_info "Install directory: $INSTALL_DIR"
    
    # Get version
    if [[ "$VERSION" == "latest" ]]; then
        log_info "Fetching latest version information..."
        VERSION=$(get_latest_version)
    fi
    
    log_info "Version: $VERSION"
    echo
    
    # Install
    install_amlc "$PLATFORM" "$VERSION" "$install_type"
    
    echo
    log_success "Installation complete!"
    log_info "Try: amlc build . -bt linux-x64"
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi