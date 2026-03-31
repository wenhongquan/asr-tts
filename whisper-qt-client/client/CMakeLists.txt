cmake_minimum_required(VERSION 3.16)
project(whisper_client VERSION 1.0.0 LANGUAGES CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets Multimedia WebSockets)

set(SOURCES
    main.cpp
    mainwindow.cpp
    audiocapture.mm
    asrclient.cpp
)

set(HEADERS
    mainwindow.h
    audiocapture.h
    asrclient.h
)

set(UI_FILES
    mainwindow.ui
)

qt_add_executable(whisper_client
    ${SOURCES}
    ${HEADERS}
    ${UI_FILES}
)

# Set Info.plist for macOS microphone permission
set_target_properties(whisper_client PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
)

target_link_libraries(whisper_client PRIVATE
    Qt6::Core
    Qt6::Widgets
    Qt6::Multimedia
    Qt6::WebSockets
    "-framework AVFoundation"
    "-framework AudioToolbox"
)

if(WIN32)
    set_target_properties(whisper_client PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()
