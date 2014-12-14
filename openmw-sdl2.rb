require 'formula'

class OpenmwSdl2 < Formula
  homepage 'http://www.libsdl.org/'
  url 'http://libsdl.org/release/SDL2-2.0.3.tar.gz'
  sha1 '21c45586a4e94d7622e371340edec5da40d06ecc'

  bottle do
    root_url 'http://downloads.openmw.org/osx/bottles'
    cellar :any
    revision 2
    sha1 "338914173be51ef17bfef13eccc2ef432426b5be" => :mavericks
    sha1 "8eb98e8136b0fc0066695ee3bb84b8f2d5b6d89c" => :yosemite
  end

  keg_only "We prefer keg-only to avoid clashes with master repo formulae"

  head do
    url 'http://hg.libsdl.org/SDL', :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?

    %w{ CFLAGS CXXFLAGS LDFLAGS OBJCFLAGS OBJCXXFLAGS }.each do |compiler_flag|
      ENV.append compiler_flag, "-mmacosx-version-min=10.6"
    end

    args = %W[--prefix=#{prefix}]
    # LLVM-based compilers choke on the assembly code packaged with SDL.
    args << '--disable-assembly' if ENV.compiler == :llvm or (ENV.compiler == :clang and MacOS.clang_build_version < 421)
    args << '--without-x'

    system './configure', *args
    system "make install"
  end

  test do
    system "#{bin}/sdl2-config", "--version"
  end
end
