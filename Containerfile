## 1. BUILD ARGS
# These allow changing the produced image by passing different build args to adjust
# the source from which your image is built.
# Build args can be provided on the commandline when building locally with:
#   podman build -f Containerfile --build-arg FEDORA_VERSION=40 -t local-image

# SOURCE_IMAGE arg can be anything from ublue upstream which matches your desired version:
# See list here: https://github.com/orgs/ublue-os/packages?repo_name=main
# - "silverblue"
# - "kinoite"
# - "sericea"
# - "onyx"
# - "lazurite"
# - "vauxite"
# - "base"
#
#  "aurora", "bazzite", "bluefin" or "ucore" may also be used but have different suffixes.
ARG SOURCE_IMAGE="aurora"

## SOURCE_SUFFIX arg should include a hyphen and the appropriate suffix name
# These examples all work for silverblue/kinoite/sericea/onyx/lazurite/vauxite/base
# - "-main"
# - "-nvidia"
# - "-asus"
# - "-asus-nvidia"
# - "-surface"
# - "-surface-nvidia"
#
# aurora, bazzite and bluefin each have unique suffixes. Please check the specific image.
# ucore has the following possible suffixes
# - stable
# - stable-nvidia
# - stable-zfs
# - stable-nvidia-zfs
# - (and the above with testing rather than stable)
ARG SOURCE_SUFFIX="-dx"

## SOURCE_TAG arg must be a version built for the specific image: eg, 39, 40, gts, latest
ARG SOURCE_TAG="latest"


### 2. SOURCE IMAGE
## this is a standard Containerfile FROM using the build ARGs above to select the right upstream image
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}


### 3. MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY system_files /

COPY build_files /tmp/

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit

# Install Waydroid
RUN curl -Lo /etc/yum.repos.d/_copr_kylegospo-bazzite.repo https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-bazzite-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    ostree container commit
# lzip is needed for the waydroid configuration script
RUN rpm-ostree install waydroid lzip && ostree container commit
# Bazzite does this so I will do it too
RUN sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh && \
    ostree container commit

# Enable the Bazzite Waydroid Justfile
RUN echo "import \"/usr/share/ublue-os/just/82-bazzite-waydroid.just\"" >> /usr/share/ublue-os/justfile && \
    ostree container commit

RUN systemctl enable waydroid-workaround.service && \
    systemctl disable waydroid-container.service && \
    ostree container commit

RUN curl -Lo /usr/bin/waydroid-choose-gpu https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh && \
    chmod +x /usr/bin/waydroid-choose-gpu && \
    ostree container commit

# Enable the Waydroid config fix service
RUN systemctl enable waydroid-config-fix.service && ostree container commit

# Disable the Bazzite repo now that we've gotten the packages from it
RUN sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    ostree container commit

    
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
