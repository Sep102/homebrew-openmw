require 'formula'

class OpenmwOgre19 < Formula

    homepage 'http://www.ogre3d.org'
    url 'https://bitbucket.org/sinbad/ogre/get/v1-9-0.tar.bz2'
    sha1 'a6afe1e2884160b9b4926de14cc20ddad090ee07'
    version '1.9.0'

    depends_on 'cmake' => :build
    depends_on 'openmw-boost' => "without-python"

    resource 'dependencies' do
        url 'https://sourceforge.net/projects/ogre/files/ogre-dependencies-mac/1.8/OgreDependencies_OSX_20120525.zip/download'
        sha1 '75f173994b25a22eeb3b782cdf17222b336b44f6'
    end

    def patches
        # Fix frameworks install name
        "https://gist.github.com/corristo/8982334/raw/9916b960561bc869bb8ced277e1b62098cb7b5bd/ogre19-install-name-fix.diff"
        # Fix missing framework headers
        "https://gist.github.com/corristo/8982334/raw/492d351323318721a882198e9c8927cca8a2e35e/ogre19-fix-framework-headers.diff"
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
