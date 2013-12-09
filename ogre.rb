require 'formula'

class Ogre < Formula

    homepage 'http://www.ogre3d.org'
    url 'https://bitbucket.org/sinbad/ogre', :using => :hg, :tag => 'v1-8-1'
    version '1.8.1'

    depends_on 'cmake' => :build
    depends_on 'boost'

    resource 'dependencies' do
        url 'https://sourceforge.net/projects/ogre/files/ogre-dependencies-mac/1.8/OgreDependencies_OSX_20120525.zip/download'
        sha1 '75f173994b25a22eeb3b782cdf17222b336b44f6'
    end

    def patches
        # Avoid calling install_name_tool on Ogre.framework
        "https://gist.github.com/corristo/7867361/raw/9fe11e442a5b6a5a529ac39bbffa8b48317ac24a/no-framework-install-name.diff"
    end

    def install

        resource('dependencies').stage do
            system "rm", "-rf", "Dependencies/include/boost"
            system "rm", "-rf", "Dependencies/lib/libboost*"

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
