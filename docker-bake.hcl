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
    platforms = ["linux/arm64", "linux/amd64"]
    push = true
    cache = false
    progress = "plain"
}
