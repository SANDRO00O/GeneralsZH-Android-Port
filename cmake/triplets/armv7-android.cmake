# Overlay triplet for Android ARMv7 (armeabi-v7a).
# Keep the same Android API level and C++ runtime as the ARM64 port so
# vcpkg-built static dependencies are ABI-compatible with the engine.
# Requires ANDROID_NDK_HOME in the environment (vcpkg reads it to find the NDK).
set(VCPKG_TARGET_ARCHITECTURE arm)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Android)
set(VCPKG_CMAKE_SYSTEM_VERSION 28)
set(VCPKG_MAKE_BUILD_TRIPLET "--host=armv7a-linux-androideabi")
set(VCPKG_CMAKE_CONFIGURE_OPTIONS -DANDROID_ABI=armeabi-v7a -DANDROID_PLATFORM=android-28 -DANDROID_STL=c++_shared)
