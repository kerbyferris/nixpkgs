{ stdenv, fetchurl, pkgconfig, fontconfig, autoreconfHook
, withJava ? false, jdk ? null, ant ? null
, withAACS ? false, libaacs ? null
, withBDplus ? false, libbdplus ? null
, withMetadata ? true, libxml2 ? null
, withFonts ? true, freetype ? null
}:

with stdenv.lib;

assert withJava -> jdk != null && ant != null;
assert withAACS -> libaacs != null;
assert withBDplus -> libbdplus != null;
assert withMetadata -> libxml2 != null;
assert withFonts -> freetype != null;

# Info on how to use:
# https://wiki.archlinux.org/index.php/BluRay

stdenv.mkDerivation rec {
  name = "libbluray-${version}";
  version  = "1.0.0";

  src = fetchurl {
    url = "http://get.videolan.org/libbluray/${version}/${name}.tar.bz2";
    sha256 = "1k3lag4lxi2jjd3zh4wcb5l3hadzm54j5kagh92yzfy76p9svqzp";
  };

  patches = optional withJava ./BDJ-JARFILE-path.patch;

  nativeBuildInputs = [ pkgconfig autoreconfHook ]
                      ++ optionals withJava [ ant ]
                      ;

  buildInputs = [ fontconfig ]
                ++ optional withJava jdk
                ++ optional withMetadata libxml2
                ++ optional withFonts freetype
                ;

  propagatedBuildInputs = optional withAACS libaacs;

  NIX_LDFLAGS = [
    (optionalString withAACS   "-L${libaacs}/lib -laacs")
    (optionalString withBDplus "-L${libbdplus}/lib -lbdplus")
  ];

  preConfigure = ''
    ${optionalString withJava ''export JDK_HOME="${jdk.home}"''}
  '';

  configureFlags =  with stdenv.lib;
                    optional (! withJava) "--disable-bdjava"
                 ++ optional (! withMetadata) "--without-libxml2"
                 ++ optional (! withFonts) "--without-freetype"
                 ;

  meta = with stdenv.lib; {
    homepage = http://www.videolan.org/developers/libbluray.html;
    description = "Library to access Blu-Ray disks for video playback";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ abbradar ];
    platforms = platforms.unix;
  };
}
