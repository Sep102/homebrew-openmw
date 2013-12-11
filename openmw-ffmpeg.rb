require 'formula'

class OpenmwFfmpeg < Formula
  homepage 'http://ffmpeg.org/'
  url 'http://ffmpeg.org/releases/ffmpeg-1.2.4.tar.bz2'
  sha1 'ee73a05bde209fc23441c7e49767c1b7a4b6f124'

  depends_on 'pkg-config' => :build
  depends_on 'yasm' => :build

  def install
    args = ["--prefix=#{prefix}",
            "--disable-ffplay",
            "--disable-ffprobe",
            "--disable-ffserver",
            "--disable-iconv",
            "--disable-manpages",
            "--disable-demuxer=matroska",
            "--cc=#{ENV.cc}",
            "--host-cflags=\"#{ENV.cflags} -mmacosx-version-min=10.6\"",
            "--host-ldflags=\"#{ENV.ldflags} -mmacosx-version-min=10.6\""
           ]

    system "./configure", *args

    if MacOS.prefer_64_bit?
      inreplace 'config.mak' do |s|
        shflags = s.get_make_var 'SHFLAGS'
        if shflags.gsub!(' -Wl,-read_only_relocs,suppress', '')
          s.change_make_var! 'SHFLAGS', shflags
        end
      end
    end

    system "make install"
  end

end
