#!/bin/bash

# sh build_ohos.sh . entry/src/main/cpp build

# 默认变量值
DEFAULT_PROJECT_DIR="$(pwd)"
DEFAULT_SOURCE_DIR="${DEFAULT_PROJECT_DIR}/entry/src/main/cpp"
DEFAULT_BUILD_DIR="${DEFAULT_PROJECT_DIR}/entry/.cxx/default/default/debug/arm64-v8a"

# 提示信息
show_usage() {
  echo "Usage: $0 [PROJECT_DIR] [SOURCE_DIR] [BUILD_DIR]"
  echo "  PROJECT_DIR: Root directory of the project (default: current directory)"
  echo "  SOURCE_DIR:  Path to the source files (default: ${DEFAULT_SOURCE_DIR})"
  echo "  BUILD_DIR:   Path to the build directory (default: ${DEFAULT_BUILD_DIR})"
}

# 检查是否需要显示帮助信息
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_usage
  exit 0
fi

# 解析命令行参数
PROJECT_DIR="${1:-$DEFAULT_PROJECT_DIR}"
SOURCE_DIR="${2:-$DEFAULT_SOURCE_DIR}"
BUILD_DIR="${3:-$DEFAULT_BUILD_DIR}"

OUTPUT_DIR="${PROJECT_DIR}/entry/build/default/intermediates/cmake/default/obj/arm64-v8a"
# OHOS_SDK_NATIVE="/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native"
# oh full sdk for m1 macos /Users/charles/Downloads/sdk/packages/ohos-sdk/darwin/native 
OHOS_SDK_NATIVE="/Users/charles/Downloads/sdk/packages/ohos-sdk/darwin/native"
TOOLCHAIN_FILE="/Applications/DevEco-Studio.app/Contents/sdk/default/hms/native/build/cmake/hmos.toolchain.cmake"
CMAKE_BIN="/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native/build-tools/cmake/bin/cmake"
NINJA_BIN="/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native/build-tools/cmake/bin/ninja"

# 检查路径是否存在
if [ ! -d "${PROJECT_DIR}" ]; then
  echo "Error: Project directory '${PROJECT_DIR}' does not exist."
  exit 1
fi

if [ ! -d "${SOURCE_DIR}" ]; then
  echo "Error: Source directory '${SOURCE_DIR}' does not exist."
  exit 1
fi

if [ ! -d "${OHOS_SDK_NATIVE}" ]; then
  echo "Error: OHOS SDK native path '${OHOS_SDK_NATIVE}' does not exist."
  exit 1
fi

# 创建构建目录
mkdir -p "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/hvigor/arm64-v8a"
echo "" > "${BUILD_DIR}/hvigor/arm64-v8a/summary.cmake"

# 执行 CMake 配置
echo "> hvigor DEBUG Configuring project with CMake..."
"${CMAKE_BIN}" \
  -H"${SOURCE_DIR}" \
  -B"${BUILD_DIR}" \
  -DOHOS_ARCH=arm64-v8a \
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="${OUTPUT_DIR}" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DOHOS_SDK_NATIVE="${OHOS_SDK_NATIVE}" \
  -DCMAKE_SYSTEM_NAME=OHOS \
  -DCMAKE_OHOS_ARCH_ABI=arm64-v8a \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
  -GNinja \
  -DCMAKE_MAKE_PROGRAM="${NINJA_BIN}" \
  -DCMAKE_FIND_ROOT_PATH="${BUILD_DIR}/hvigor/arm64-v8a" \
  --no-warn-unused-cli \
  -DHMOS_SDK_NATIVE="${OHOS_SDK_NATIVE}"
# -DPACKAGE_FIND_FILE="${BUILD_DIR}/hvigor/arm64-v8a/summary.cmake" 


# 检查配置结果
if [ $? -eq 0 ]; then
  echo "> hvigor DEBUG CMake configuration completed successfully."
else
  echo "> hvigor DEBUG CMake configuration failed."
  exit 1
fi

# 构建项目
echo "> hvigor DEBUG task-runner Executing task :entry:default@BuildNativeWithNinja"
echo "> hvigor DEBUG BuildNativeWithNinja Use tool [Ninja]"
echo "["
echo "  '${NINJA_BIN}',"
echo "  '-C',"
echo "  '${BUILD_DIR}'"
echo "]"

"${NINJA_BIN}" -C "${BUILD_DIR}"

if [ $? -eq 0 ]; then
  echo "> hvigor DEBUG Build completed successfully."
else
  echo "> hvigor DEBUG Build failed."
  exit 1
fi