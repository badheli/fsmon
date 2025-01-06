cmake_minimum_required(VERSION 3.10)

# 项目名称
project(fsmon C)

# 设置 Android 配置（如果需要，取消注释并设置正确的路径）
# set(CMAKE_SYSTEM_NAME Android)
# set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
# set(CMAKE_ANDROID_NDK /path/to/android-ndk)
# set(CMAKE_ANDROID_STL_TYPE c++_shared)

# 开启优化和调试支持
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -O3 -g -DHAVE_FANOTIFY=1 -DHAVE_SYS_FANOTIFY=1 -DFSMON_VERSION=\"\\\"1.0.0\\\"\"")
# add_definitions(-DHAVE_FANOTIFY=1 -DFSMON_VERSION="1.0.0")
# 设置编译输出路径
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 明确列出需要编译的源代码文件
set(SRC_FILES
    main.c
    util.c
    backend/devfsev.c
    backend/fanotify.c
    backend/fsevapi.c
    backend/inotify.c
    backend/kdebug.c
    backend/kqueue.c
)

# 打印源文件以供调试
message(STATUS "Source files: ${SRC_FILES}")

# 添加可执行目标
add_executable(fsmon_ohos ${SRC_FILES})

# 添加头文件目录
target_include_directories(fsmon_ohos PRIVATE
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_SOURCE_DIR}/backend
    ${PROJECT_SOURCE_DIR}/backend/kdebug
)