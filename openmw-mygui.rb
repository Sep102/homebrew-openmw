require 'formula'

class OpenmwMygui < Formula

  homepage 'http://mygui.info'
  url 'http://sourceforge.net/projects/my-gui/files/MyGUI/MyGUI_3.2.0/MyGUI_3.2.0.zip/download'
  sha1 'a9cc2424d5f4bacbd454631166b2452236c9517b'
  version '3.2.0'

  bottle do
    root_url 'https://dl.dropboxusercontent.com/u/28481/openmw/bottles'
    cellar :any
    sha1 "7e5220758b7f7e4b0359508d7426f78da0fb291c" => :mavericks
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
