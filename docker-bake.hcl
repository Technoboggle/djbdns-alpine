# docker-bake.hcl
group "default" {
    targets = ["app"]
}

target "app" {
    context = "."
    dockerfile = "Dockerfile"
    tags = ["technoboggle/djbdns-alpine:${DJBDNS_VERSION}-${ALPINE_VERSION}", "technoboggle/djbdns-alpine:${DJBDNS_VERSION}", "technoboggle/djbdns-alpine:latest"]
    args = {
        ALPINE_VERSION = "${ALPINE_VERSION}"
        DJBDNS_VERSION = "${DJBDNS_VERSION}"
        DEAMONTOOLS="${DEAMONTOOLS}"
        UCSPI_TCP="${UCSPI_TCP}"

        MAINTAINER_NAME = "${MAINTAINER_NAME}"
        AUTHORNAME = "${AUTHORNAME}"
        AUTHORS = "${AUTHORS}"
        VERSION = "${VERSION}"

        SCHEMAVERSION = "${SCHEMAVERSION}"
        NAME = "${NAME}"
        DESCRIPTION = "${DESCRIPTION}"
        URL = "${URL}"
        VCS_URL = "${VCS_URL}"
        VENDOR = "${VENDOR}"
        BUILDVERSION = "${BUILD_VERSION}"
        BUILD_DATE="${BUILD_DATE}"
        DOCKERCMD:"${DOCKERCMD}"
        USAGE:"${USAGE}"
    }
    # platforms = ["linux/386", "linux/amd64", "linux/arm/v6", "linux/arm/v7", "linux/arm64/v8", "linux/ppc64le", "linux/riscv64", "linux/s390x"]
    # The following are the only platform builds which succeed on MAC OS
    platforms = ["linux/amd64", "linux/arm64/v8", "linux/arm64"]
    push = true
    cache = false
    progress = "plain"
}
