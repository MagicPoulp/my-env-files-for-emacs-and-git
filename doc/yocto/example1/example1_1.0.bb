DESCRIPTION = "simple example"
SECTION = "base"
LICENSE = "CLOSED"
PR = "r0"
PN = 'example1'

SRCREV = "${AUTOREV}"
PV = "1.0+git${SRCPV}"

#SRC_URI = "git://git@git:project/oem/platform/tools/palantir;protocol=ssh;tag=v${PV}"
#SRC_URI = "git://git@git/project/oem/platform/tools/palantir;protocol=ssh"
SRC_URI = "git://tt-gerrit.tobii.intra/Mimer;protocol=ssh;branch=yocto"

do_compile () {
         echo "running my do_compile"
}

do_install () {
         echo "do install"
#         install -d ${D}${bindir}
#         install -m 0755 ${WORKDIR}/Makefile ${D}${bindir}/
}
