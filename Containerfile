ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG BASE_IMAGE_FLAVOR="${BASE_IMAGE_FLAVOR:-main}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.10.4-201.fsync.fc40.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$BASE_IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG JUPITER_FIRMWARE_VERSION="${JUPITER_FIRMWARE_VERSION:-jupiter-20240813.1}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

FROM ghcr.io/ublue-os/${KERNEL_FLAVOR}-kernel:${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS fsync
FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods-extra

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS hostdeck

ARG IMAGE_NAME="${IMAGE_NAME:-grymax}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.10.4-201.fsync.fc40.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG JUPITER_FIRMWARE_VERSION="${JUPITER_FIRMWARE_VERSION:-jupiter-20240813.1}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/desktop/shared system_files/desktop/${BASE_IMAGE_NAME} /

# Install kernel-fsync
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=fsync,src=/tmp/rpms,dst=/tmp/fsync-rpms \
    rpm-ostree cliwrap install-to-root / && \
    if [[ "${KERNEL_FLAVOR}" =~ "fsync" ]]; then \
        echo "Will install ${KERNEL_FLAVOR} kernel" && \
        ls -l /tmp/fsync-rpms/ && \
        rpm-ostree override replace \
        --experimental \
            /tmp/fsync-rpms/kernel-[0-9]*.rpm \
            /tmp/fsync-rpms/kernel-core-*.rpm \
            /tmp/fsync-rpms/kernel-modules-*.rpm \
            /tmp/fsync-rpms/kernel-uki-virt-*.rpm \
    ; else \
        echo "will use kernel from ${KERNEL_FLAVOR} images" \
    ; fi && \
    rpm-ostree install \
        scx-scheds && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit