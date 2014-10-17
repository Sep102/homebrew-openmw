require 'formula'

class OpenmwMygui < Formula

    homepage 'http://mygui.info'
    url 'https://github.com/MyGUI/mygui/archive/MyGUI3.2.1.zip'
    sha1 'dbc2910861f747c1be46dbdb756320838720f855'
    version '3.2.1'

    bottle do
        root_url 'http://downloads.openmw.org/osx/bottles'
        cellar :any
        sha1 "524f739533e75d73e74b58c9aa98b39a248a5b76" => :mavericks
    end

    depends_on 'cmake' => :build
    depends_on 'openmw-ogre19'

    resource 'dependencies' do
        url 'https://sourceforge.net/projects/ogre/files/ogre-dependencies-mac/1.8/OgreDependencies_OSX_20120525.zip/download'
        sha1 '75f173994b25a22eeb3b782cdf17222b336b44f6'
    end

    def install

        resource('dependencies').stage do
            system "rm", "-rf", "Dependencies/include/boost"
            system "rm", "-rf", "Dependencies/include/OIS"

            buildpath.install Dir['Dependencies']
        end

        args = []

        args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
        args << "-DCMAKE_BUILD_TYPE=Release"
        args << "-DCMAKE_C_COMPILER=#{ENV.cc}"
        args << "-DCMAKE_CXX_COMPILER=#{ENV.cxx}"
        args << "-DCMAKE_C_FLAGS=-mmacosx-version-min=10.6"
        args << "-DCMAKE_CXX_FLAGS=-mmacosx-version-min=10.6"
        args << "-DCMAKE_SHARED_LINKER_FLAGS=-mmacosx-version-min=10.6"
        args << "-DCMAKE_FRAMEWORK_PATH=#{HOMEBREW_PREFIX}/lib/macosx/Release"
        args << "-DMYGUI_BUILD_TOOLS=FALSE"
        args << "-DMYGUI_BUILD_DEMOS=FALSE"
        args << "-DMYGUI_BUILD_PLUGINS=FALSE"
        args << "-DMYGUI_DEPENDENCIES_DIR=Dependencies"

        system "cmake", *args
        system "make"
        system "make install"
    end
end
