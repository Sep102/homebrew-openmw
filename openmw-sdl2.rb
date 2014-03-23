require 'formula'

class OpenmwSdl2 < Formula
  homepage 'http://www.libsdl.org/'
  url 'http://libsdl.org/release/SDL2-2.0.2.tar.gz'
  sha1 '304c7cd3dddca98724a3e162f232a8a8f6e1ceb3'

  bottle do
    root_url 'https://dl.dropboxusercontent.com/u/28481/openmw/bottles'
    cellar :any
    sha1 "83f489d35151c4030e9ed8866741bc212024d19b" => :mavericks
  end

  head do
    url 'http://hg.libsdl.org/SDL', :using => :hg

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
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
      ENV.append compiler_flag, "-mmacosx-version-min=10.7"
    end

    args = %W[--prefix=#{prefix}]
    # LLVM-based compilers choke on the assembly code packaged with SDL.
    args << '--disable-assembly' if ENV.compiler == :llvm or (ENV.compiler == :clang and MacOS.clang_build_version < 421)
    args << '--without-x'

    system './configure', *args
    system "make install"
  end

  def test
    system "#{bin}/sdl2-config", "--version"
  end
end
