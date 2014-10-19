require 'formula'

class OpenmwOgre19 < Formula

    homepage 'http://www.ogre3d.org'
    url 'https://bitbucket.org/sinbad/ogre/get/v1-9-0.tar.bz2'
    sha1 'a6afe1e2884160b9b4926de14cc20ddad090ee07'
    version '1.9.0'

    bottle do
        root_url 'http://downloads.openmw.org/osx/bottles'
        revision 1
        sha1 "40965abbd9e81d4ccb5cdc091c8a0d37eecdd08b" => :mavericks
        sha1 "8116ed2d46edf21e97a4537112fbb4be14870a4a" => :yosemite
    end

    depends_on 'cmake' => :build
    depends_on 'openmw-boost'

    resource 'dependencies' do
        url 'https://sourceforge.net/projects/ogre/files/ogre-dependencies-mac/1.8/OgreDependencies_OSX_20120525.zip/download'
        sha1 '75f173994b25a22eeb3b782cdf17222b336b44f6'
    end

    def patches
        DATA
    end

    def install

        resource('dependencies').stage do
            system "rm", "-rf", "Dependencies/include/boost"
            system "rm", "-rf", "Dependencies/include/OIS"

            buildpath.install Dir['Dependencies']
        end

        args = []

        args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
        args << "-DOGRE_BUILD_SAMPLES=FALSE"
        args << "-DOGRE_BUILD_TOOLS=FALSE"
        args << "-DCMAKE_BUILD_TYPE=Release"
        args << "-DCMAKE_C_COMPILER=#{ENV.cc}"
        args << "-DCMAKE_CXX_COMPILER=#{ENV.cxx}"
        args << "-DCMAKE_C_FLAGS=-mmacosx-version-min=10.6"
        args << "-DCMAKE_CXX_FLAGS=-mmacosx-version-min=10.6"
        args << "-DCMAKE_SHARED_LINKER_FLAGS=-mmacosx-version-min=10.6"

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
