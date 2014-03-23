require 'formula'

class OpenmwMygui < Formula

  homepage 'http://mygui.info'
  url 'http://sourceforge.net/projects/my-gui/files/MyGUI/MyGUI_3.2.0/MyGUI_3.2.0.zip/download'
  sha1 'a9cc2424d5f4bacbd454631166b2452236c9517b'
  version '3.2.0'

  bottle do
    root_url 'https://dl.dropboxusercontent.com/u/28481/openmw/bottles'
    cellar :any
    revision 1
    sha1 "d41116c8cc70226ab8659a8b6d36ea70050ed53a" => :mavericks
  end

  option :cxx11

  depends_on 'cmake' => :build
  if build.cxx11?
    depends_on 'openmw-ogre19' => 'c++11'
  else
    depends_on 'openmw-ogre19'
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
    args << "-DCMAKE_BUILD_TYPE=Release"
    args << "-DCMAKE_C_COMPILER=#{ENV.cc}"
    args << "-DCMAKE_CXX_COMPILER=#{ENV.cxx}"
    args << "-DCMAKE_CXX_FLAGS='-stdlib=libc++ -std=c++11'" if build.cxx11?
    args << "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7"
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
