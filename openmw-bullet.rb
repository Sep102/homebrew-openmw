require 'formula'

class OpenmwBullet < Formula
  homepage 'http://bulletphysics.org/wordpress/'
  url 'http://bullet.googlecode.com/files/bullet-2.82-r2704.tgz'
  version '2.82'
  sha1 'a0867257b9b18e9829bbeb4c6c5872a5b29d1d33'
  head 'http://bullet.googlecode.com/svn/trunk/'

  bottle do
    root_url 'http://downloads.openmw.org/osx/bottles'
    revision 1
    sha1 "063b011bc0d06d92ea20c82bc30615a78a248500" => :mavericks
    sha1 "2071e49debf2db12d19a6a6454437fa68c22a529" => :yosemite
  end

  depends_on 'cmake' => :build

  option :universal
  option 'framework',        'Build Frameworks'
  option 'shared',           'Build shared libraries'
  option 'build-demo',       'Build demo applications'
  option 'build-extra',      'Build extra library'
  option 'double-precision', 'Use double precision'

  def install
    args = []

    if build.include? "framework"
      args << "-DBUILD_SHARED_LIBS=ON" << "-DFRAMEWORK=ON"
      args << "-DCMAKE_INSTALL_PREFIX=#{frameworks}"
      args << "-DCMAKE_INSTALL_NAME_DIR=#{frameworks}"
    else
      args << "-DBUILD_SHARED_LIBS=ON" if build.include? "shared"
      args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    end

    args << "-DCMAKE_OSX_ARCHITECTURES='#{Hardware::CPU.universal_archs.as_cmake_arch_flags}" if build.universal?
    args << "-DUSE_DOUBLE_PRECISION=ON" if build.include? "double-precision"

    args << "-DBUILD_DEMOS=OFF" unless build.include? "build-demo"

    # Demos require extras, see:
    # https://code.google.com/p/bullet/issues/detail?id=767&thanks=767&ts=1384333052
    if build.include? "build-extra" or build.include? "build-demo"
      args << "-DINSTALL_EXTRA_LIBS=ON"
    else
      args << "-DBUILD_EXTRAS=OFF"
    end

    args <<"-DCMAKE_OSX_SYSROOT=macosx10.9"
    args <<"-DCMAKE_OSX_DEPLOYMENT_TARGET=10.6"

    system "cmake", *args
    system "make"
    system "make install"

    prefix.install 'Demos' if build.include? "build-demo"
    prefix.install 'Extras' if build.include? "build-extra"
  end
end
