require 'formula'

class OpenmwSdl2 < Formula
  homepage 'http://www.libsdl.org/'
  url 'http://libsdl.org/release/SDL2-2.0.3.tar.gz'
  sha1 '21c45586a4e94d7622e371340edec5da40d06ecc'

  bottle do
    root_url 'https://dl.dropboxusercontent.com/u/28481/openmw/bottles'
    cellar :any
    sha1 "338914173be51ef17bfef13eccc2ef432426b5be" => :mavericks
  end

  head do
    url 'http://hg.libsdl.org/SDL', :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    # we have to do this because most build scripts assume that all sdl modules
    # are installed to the same prefix. Consequently SDL stuff cannot be
    # keg-only but I doubt that will be needed.
    inreplace %w[sdl2.pc.in sdl2-config.in], '@prefix@', HOMEBREW_PREFIX

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
