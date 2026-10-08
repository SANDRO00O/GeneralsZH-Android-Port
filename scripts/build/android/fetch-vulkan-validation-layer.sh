#!/bin/bash
# Fetch the prebuilt Khronos Vulkan Validation Layer for the selected Android ABI
# and stage it for bundling into the APK. The layer is diagnostic-only.
#
# Opt-in diagnostic tool: SDL3Main.cpp only sets DXVK_DEBUG=validation when a
# tester drops dxvk_validation.txt into the game data folder. Off by default,
# it's pure dead weight in a normal launch -- but for a crash whose PC/LR
# resolve inside the vendor driver itself (e.g. issue #9's libGLES_mali.so
# SIGSEGV) it turns "the driver died" into an actual Vulkan API-misuse
# message, since Android's loader auto-discovers a layer bundled in a
# debuggable app's own jniLibs, and DXVK's debug-callback output already
# goes to stderr on non-Windows (log.cpp) -- i.e. straight into the
# generals-stderr.log the tester already knows how to export.
set -euo pipefail

VVL_VERSION="1.4.357.0"
VVL_TAG="vulkan-sdk-${VVL_VERSION}"
VVL_URL="https://github.com/KhronosGroup/Vulkan-ValidationLayers/releases/download/${VVL_TAG}/android-binaries-${VVL_VERSION}.zip"
ANDROID_ABI="${GX_ANDROID_ABI:-arm64-v8a}"
case "${ANDROID_ABI}" in
    arm64-v8a|armeabi-v7a) ;;
    *) echo "ERROR: unsupported GX_ANDROID_ABI='${ANDROID_ABI}'"; exit 1 ;;
esac
DEST="${GX_VULKAN_VALIDATION:-${HOME}/GeneralsX/android-staging/vulkan_validation}"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

if [[ -f "${DEST}/libVkLayer_khronos_validation.so" ]]; then
    echo "Vulkan validation layer already staged at ${DEST}"
    exit 0
fi

echo "==> Downloading Vulkan Validation Layers ${VVL_VERSION} (Android binaries)"
curl -fL -o "${TMP}/android-binaries.zip" "${VVL_URL}"
unzip -q "${TMP}/android-binaries.zip" -d "${TMP}/extracted"

LIB="$(find "${TMP}/extracted" -path "*/${ANDROID_ABI}/libVkLayer_khronos_validation.so" | head -1)"
if [[ -z "${LIB}" || ! -f "${LIB}" ]]; then
    echo "WARNING: libVkLayer_khronos_validation.so not found for ${ANDROID_ABI} in ${VVL_URL}"
    exit 0
fi

if command -v file >/dev/null 2>&1; then
    ARCH="$(file -b "${LIB}")"
    if [[ "${ANDROID_ABI}" == "arm64-v8a" ]]; then
        ARCH_OK="${ARCH}"
        [[ "${ARCH_OK}" == *"ARM aarch64"* || "${ARCH_OK}" == *"AArch64"* ]] || { echo "ERROR: validation layer is not AArch64 (got: ${ARCH})"; exit 1; }
    else
        ARCH_OK="${ARCH}"
        [[ "${ARCH_OK}" == *"ARM"* && "${ARCH_OK}" != *"aarch64"* && "${ARCH_OK}" != *"AArch64"* ]] || { echo "ERROR: validation layer is not 32-bit ARM (got: ${ARCH})"; exit 1; }
    fi
    if false; then
        echo "UNREACHABLE"
        exit 1
    fi
fi

mkdir -p "${DEST}"
cp "${LIB}" "${DEST}/libVkLayer_khronos_validation.so"
echo "==> Staged Vulkan Validation Layers ${VVL_VERSION} (${ANDROID_ABI}) at ${DEST}"
