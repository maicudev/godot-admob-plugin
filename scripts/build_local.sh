#!/bin/bash
# MIT License
#
# Copyright (c) 2023-present Poing Studios

show_help() {
    echo "Usage: ./scripts/build_local.sh [android|ios|all] <godot_version>"
    echo ""
    echo "Arguments:"
    echo "  [platform]       android, ios, or all (default: all)"
    echo "  <godot_version>  The target Godot version (e.g. 3.6.3)"
    echo ""
    echo "Examples:"
    echo "  ./scripts/build_local.sh all 3.6.3"
    echo "  ./scripts/build_local.sh ios 3.6.3"
    echo "  ./scripts/build_local.sh android 3.6.3"
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

PLATFORM=${1:-all}
GODOT_VERSION=$2

if [ -z "$GODOT_VERSION" ]; then
    echo "[ERROR] Please specify target Godot version (e.g., 3.6.3)."
    show_help
    exit 1
fi

ROOT_DIR=$(pwd)
EDITOR_DIR="$ROOT_DIR/platforms/godot_editor"

# Android Gradle Plugin 8.1.4 requires JDK 17. Newer Android Studio builds
# may set JAVA_HOME to a JDK that is newer than the Gradle wrapper supports
# (for example, Java 25 reports class file major version 69).
configure_android_java() {
    java_major_version() {
        "$1/bin/java" -version 2>&1 \
            | sed -n 's/.*version "\([0-9][0-9]*\).*/\1/p' \
            | head -n 1
    }

    local candidate
    local major
    local candidates=()

    if [ -n "${JAVA_HOME:-}" ]; then
        candidates+=("$JAVA_HOME")
    fi

    # Keep JAVA_HOME when it already points to the required toolchain.
    for candidate in "${candidates[@]}"; do
        if [ -x "$candidate/bin/java" ]; then
            major=$(java_major_version "$candidate")
            if [ "$major" = "17" ]; then
                export PATH="$candidate/bin:$PATH"
                echo "[INFO] Using Java $major from $candidate."
                return 0
            fi
        fi
    done

    # Common Linux installation paths. The explicit JAVA_HOME above still
    # takes precedence whenever it is a compatible JDK 17 installation.
    candidates=(
        "/usr/lib/jvm/java-17-openjdk"
        "/usr/lib/jvm/java-17-openjdk-amd64"
        "/usr/lib/jvm/jdk-17"
    )

    for candidate in "${candidates[@]}"; do
        if [ -x "$candidate/bin/java" ]; then
            major=$(java_major_version "$candidate")
            if [ "$major" = "17" ]; then
                export JAVA_HOME="$candidate"
                export PATH="$candidate/bin:$PATH"
                echo "[INFO] JAVA_HOME was incompatible; using Java $major from $candidate."
                return 0
            fi
        fi
    done

    echo "[ERROR] Android build requires JDK 17 (current JAVA_HOME is incompatible)."
    echo "[ERROR] Install JDK 17 or set JAVA_HOME to a JDK 17 installation."
    return 1
}

build_android() {
    echo ">>> Preparing Android build for Godot $GODOT_VERSION..."
    configure_android_java || exit 1
    cd "$ROOT_DIR/platforms/android" || exit 1
    chmod +x ./scripts/unix/download_godot.sh
    ./scripts/unix/download_godot.sh "$GODOT_VERSION" || exit 1
    
    echo ">>> Compiling Android plugin..."
    chmod +x gradlew
    ./gradlew build || exit 1
    
    echo ">>> Exporting Android plugin files to Godot Editor..."
    mkdir -p "$EDITOR_DIR/android/plugins"
    cp "$ROOT_DIR/platforms/android/admob/AdMob.gdap" "$EDITOR_DIR/android/plugins/"
    cp "$ROOT_DIR/platforms/android/admob/build/outputs/aar/admob-release.aar" "$EDITOR_DIR/android/plugins/"
    cp "$ROOT_DIR/platforms/android/admob/build/outputs/aar/admob-debug.aar" "$EDITOR_DIR/android/plugins/"
}

build_ios() {
    echo ">>> Preparing iOS build for Godot $GODOT_VERSION..."
    cd "$ROOT_DIR/platforms/ios" || exit 1
    chmod +x ./scripts/lib/download_godot.sh
    ./scripts/lib/download_godot.sh "$GODOT_VERSION" || exit 1
    
    chmod +x ./scripts/resolve_spm_deps.sh
    ./scripts/resolve_spm_deps.sh || exit 1
    
    echo ">>> Generating Godot binding headers..."
    chmod +x ./scripts/generate_headers.sh
    ./scripts/generate_headers.sh 3.x || exit 1
    
    echo ">>> Compiling iOS static libraries..."
    chmod +x ./scripts/release_static_library.sh
    chmod +x ./scripts/generate_static_library.sh
    ./scripts/release_static_library.sh 3.x || exit 1
    
    echo ">>> Exporting iOS plugin files to Godot Editor..."
    mkdir -p "$EDITOR_DIR/ios/plugins"
    cp -R "$ROOT_DIR/platforms/ios/bin/release/admob/"* "$EDITOR_DIR/ios/plugins/"
}

case "$PLATFORM" in
    android) build_android ;;
    ios)     build_ios ;;
    all)     build_android; build_ios ;;
    *)       echo "Invalid platform: $PLATFORM"; exit 1 ;;
esac

echo "Done!"
