DESCRIPTION = "simple example"
SECTION = "base"
LICENSE = "CLOSED"
PR = "r0"
PN = 'example2'

SRCREV = "${AUTOREV}"
PV = "1.0+git${SRCPV}"

# runtime dependency
#RDEPENDS_${PN} = "example1"
# build time dependency
DEPENDS += "example1"

#SRC_URI = "git://git@git:project/oem/platform/tools/palantir;protocol=ssh;tag=v${PV}"
#SRC_URI = "git://git@git/project/oem/platform/tools/palantir;protocol=ssh"
SRC_URI = "git://tt-gerrit.tobii.intra/Mimer;protocol=ssh;branch=yocto"

do_compile () {
         echo "running my do_compile2"
}

# required for DEPENDS
do_configure () {
         echo "running my do_configure2"
}

do_install () {
           echo "do install2"
#       install -d ${D}${bindir}
#       install -m 0755 ${WORKDIR}/helloyp ${D}${bindir}/
}
