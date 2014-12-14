require 'formula'

class OpenmwBoost < Formula
  homepage 'http://www.boost.org'
  url 'http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz/download'
  sha1 '61ed0e57d3c7c8985805bb0682de3f4c65f4b6e5'

  head 'http://svn.boost.org/svn/boost/trunk'

  bottle do
    root_url 'http://downloads.openmw.org/osx/bottles'
    cellar :any
    revision 5
    sha1 "961d7bdd16724afc70413a12f7fe6dad5cf10986" => :mavericks
    sha1 "dd0b2cdc5fb606e71f7dd3c36f83a5f089e54885" => :yosemite
  end

  keg_only "We prefer keg-only to avoid clashes with master repo formulae"

  env :userpaths

  option 'with-icu', 'Build regexp engine with icu support'
  option :cxx11

  if build.with? 'icu'
    if build.cxx11?
      depends_on 'icu4c' => 'c++11'
    else
      depends_on 'icu4c'
    end
  end

  odie 'boost: --with-c++11 has been renamed to --c++11' if build.with? 'c++11'

  # Patches boost::atomic for LLVM 3.4 as it is used on OS X 10.9 with Xcode 5.1
  def patches
    { :p2 => [
      "https://github.com/boostorg/atomic/commit/6bb71fdd.patch",
      "https://github.com/boostorg/atomic/commit/e4bde20f.patch",
    ]}
  end

  fails_with :llvm do
    build 2335
    cause "Dropped arguments to functions when linking with boost"
  end

  if Hardware::CPU.type == :ppc || Hardware::CPU.is_32_bit?
    odie 'Only x86_64 builds are supported'
  end

  def install
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?

    # Adjust the name the libs are installed under to include the path to the
    # Homebrew lib directory so executables will work when installed to a
    # non-/usr/local location.
    #
    # otool -L `which mkvmerge`
    # /usr/local/bin/mkvmerge:
    #   libboost_regex-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   libboost_filesystem-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   libboost_system-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #
    # becomes:
    #
    # /usr/local/bin/mkvmerge:
    #   /usr/local/lib/libboost_regex-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   /usr/local/lib/libboost_filesystem-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   /usr/local/lib/libboost_system-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    inreplace 'tools/build/v2/tools/darwin.jam', '-install_name "', "-install_name \"#{prefix}/lib/"

    # boost will try to use cc, even if we'd rather it use, say, gcc-4.2
    inreplace 'tools/build/v2/engine/build.sh', 'BOOST_JAM_CC=cc', "BOOST_JAM_CC=#{ENV.cc}"
    inreplace 'tools/build/v2/engine/build.jam', 'toolset darwin cc', "toolset darwin #{ENV.cc}"

    # Force boost to compile using the appropriate GCC version
    open("user-config.jam", "a") do |file|
      file.write "using darwin : : #{ENV.cxx} : <compileflags>-mmacosx-version-min=10.6 <linkflags>-mmacosx-version-min=10.6 ;\n"
    end

    # we specify libdir too because the script is apparently broken
    bargs = ["--prefix=#{prefix}", "--libdir=#{lib}"]

    if build.with? 'icu'
      icu4c_prefix = Formula.factory('icu4c').opt_prefix
      bargs << "--with-icu=#{icu4c_prefix}"
    else
      bargs << '--without-icu'
    end

    # Handle libraries that will not be built.
    without_libraries = []

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc || ENV.compiler == :llvm

    without_libraries << "python"
    without_libraries << "mpi"

    bargs << "--without-libraries=#{without_libraries.join(',')}"

    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "install"]

    args << "threading=multi"
    args << "link=shared"

    system "./bootstrap.sh", *bargs
    system "./b2", *args
  end

  def caveats
    s = ''
    # ENV.compiler doesn't exist in caveats. Check library availability
    # instead.
    if Dir.glob("#{lib}/libboost_log*").empty?
      s += <<-EOS.undent

      Building of Boost.Log is disabled because it requires newer GCC or Clang.
      EOS
    end

    if Hardware::CPU.type == :ppc || Hardware::CPU.is_32_bit? || build.universal?
      s += <<-EOS.undent

      Building of Boost.Context and Boost.Coroutine is disabled as they are
      only supported on x86_64.
      EOS
    end
    s
  end
end
