require 'formula'

class OpenmwOgre19 < Formula

    homepage 'http://www.ogre3d.org'
    url 'https://bitbucket.org/sinbad/ogre/get/v1-9-0.tar.bz2'
    sha1 'a6afe1e2884160b9b4926de14cc20ddad090ee07'
    version '1.9.0'

    bottle do
      root_url 'https://dl.dropboxusercontent.com/u/28481/openmw/bottles'
      revision 1
      sha1 "2ca7e0ddf854eae35b76113bb140f6c8fdffeff5" => :mavericks
    end

    option :cxx11

    depends_on 'cmake' => :build
    if build.cxx11?
      depends_on 'openmw-boost' => 'c++11'
    else
      depends_on 'openmw-boost'
    end

    if build.cxx11?
      resource 'dependencies' do
        url 'http://sourceforge.net/projects/ogre/files/ogre-dependencies-mac/1.9/OgreDependencies_OSX_libc%2B%2B_20130610.zip/download'
        sha1 'a9cacb347b22cfdca82e8329771a7a0b27ca495c'
      end
    else
      resource 'dependencies' do
        url 'https://sourceforge.net/projects/ogre/files/ogre-dependencies-mac/1.8/OgreDependencies_OSX_20120525.zip/download'
        sha1 '75f173994b25a22eeb3b782cdf17222b336b44f6'
      end
    end

    def patches
        DATA
    end

    def install

        resource('dependencies').stage do
            system "rm", "-rf", "Dependencies/include/boost"
            system "rm", "-rf", "Dependencies/include/OIS"
            system "rm", "-rf", "Dependencies/lib/libboost_chrono.a"
            system "rm", "-rf", "Dependencies/lib/libboost_date_time.a"
            system "rm", "-rf", "Dependencies/lib/libboost_system.a"
            system "rm", "-rf", "Dependencies/lib/libboost_thread.a"

            buildpath.install Dir['Dependencies']
        end

        args = []

        args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
        args << "-DOGRE_BUILD_SAMPLES=FALSE"
        args << "-DOGRE_BUILD_TOOLS=FALSE"
        args << "-DCMAKE_BUILD_TYPE=Release"
        args << "-DCMAKE_C_COMPILER=#{ENV.cc}"
        args << "-DCMAKE_CXX_COMPILER=#{ENV.cxx}"
        args << "-DCMAKE_OSX_ARCHITECTURES=x86_64"
        args << "-DOGRE_CONFIG_ENABLE_LIBCPP_SUPPORT=TRUE" if build.cxx11?
        args << "-DCMAKE_CXX_FLAGS='-stdlib=libc++ -std=c++11'" if build.cxx11?

        system "cmake", *args
        system "make"
        system "make install"
    end
end

__END__
diff --git a/OgreMain/CMakeLists.txt b/OgreMain/CMakeLists.txt
--- a/OgreMain/CMakeLists.txt
+++ b/OgreMain/CMakeLists.txt
@@ -302,7 +302,11 @@
         LINK_FLAGS "-framework IOKit -framework Cocoa -framework Carbon -framework OpenGL -framework CoreVideo"
     )
 
-    set(OGRE_OSX_BUILD_CONFIGURATION "$(PLATFORM_NAME)/$(CONFIGURATION)")
+    if(CMAKE_GENERATOR STREQUAL "Xcode")
+      set(OGRE_OSX_BUILD_CONFIGURATION "$(PLATFORM_NAME)/$(CONFIGURATION)")
+    else()
+      set(OGRE_OSX_BUILD_CONFIGURATION "${PLATFORM_NAME}")
+    endif()
   
    add_custom_command(TARGET OgreMain POST_BUILD
        COMMAND mkdir ARGS -p ${OGRE_BINARY_DIR}/lib/${OGRE_OSX_BUILD_CONFIGURATION}/Ogre.framework/Headers/Threading
diff --git a/CMake/Utils/OgreConfigTargets.cmake b/CMake/Utils/OgreConfigTargets.cmake
--- a/CMake/Utils/OgreConfigTargets.cmake
+++ b/CMake/Utils/OgreConfigTargets.cmake
@@ -257,7 +257,7 @@
       # Set the INSTALL_PATH so that frameworks can be installed in the application package
       set_target_properties(${LIBNAME}
          PROPERTIES BUILD_WITH_INSTALL_RPATH 1
-         INSTALL_NAME_DIR "@executable_path/../Frameworks"
+         INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/${OGRE_LIB_DIRECTORY}/${PLATFORM_NAME}/${CMAKE_BUILD_TYPE}"
       )
       set_target_properties(${LIBNAME} PROPERTIES PUBLIC_HEADER "${HEADER_FILES} ${PLATFORM_HEADERS}")
       set_target_properties(${LIBNAME} PROPERTIES XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER "YES")
diff --git a/CMakeLists.txt b/CMakeLists.txt
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -39,8 +39,13 @@
   SET(CMAKE_SIZEOF_VOID_P 4)
   set(CMAKE_XCODE_ATTRIBUTE_GCC_VERSION "com.apple.compilers.llvm.clang.1_0")
   if(OGRE_CONFIG_ENABLE_LIBCPP_SUPPORT)
-    set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
-    set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
+    if (CMAKE_GENERATOR STREQUAL "Xcode")
+      set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
+      set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
+    else ()
+      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++11")
+      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -stdlib=libc++")
+    endif ()
   endif()
 endif ()
