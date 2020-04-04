FROM ubuntu:bionic

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get dist-upgrade --yes && \
  apt-get install --yes curl sudo git jq squashfs-tools tzdata && \
  curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core' | jq '.download_url' -r) --output core.snap && \
  mkdir -p /snap/core && unsquashfs -d /snap/core/current core.snap && rm core.snap && \
  curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core18' | jq '.download_url' -r) --output core18.snap && \
  mkdir -p /snap/core18 && unsquashfs -d /snap/core18/current core18.snap && rm core18.snap && \
  curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/snapcraft?channel=candidate' | jq '.download_url' -r) --output snapcraft.snap && \
  mkdir -p /snap/snapcraft && unsquashfs -d /snap/snapcraft/current snapcraft.snap && rm snapcraft.snap && \
  apt remove --yes --purge curl jq squashfs-tools && \
  apt-get autoclean --yes && \
  apt-get clean --yes
  
# Configure git
RUN git config --global user.email "you@example.com" && git config --global user.name "Your Name"

# Generate locale
RUN apt update && apt dist-upgrade --yes && apt install --yes sudo locales && locale-gen en_US.UTF-8

# Create a snapcraft runner (TODO: move version detection to the core of snapcraft)
RUN mkdir -p /snap/bin
RUN echo "#!/bin/sh" > /snap/bin/snapcraft
RUN snap_version="$(awk '/^version:/{print $2}' /snap/snapcraft/current/meta/snap.yaml)" && echo "export SNAP_VERSION=\"$snap_version\"" >> /snap/bin/snapcraft
RUN echo 'exec "$SNAP/usr/bin/python3" "$SNAP/bin/snapcraft" "$@"' >> /snap/bin/snapcraft
RUN chmod +x /snap/bin/snapcraft

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="/snap/bin:$PATH"
ENV SNAP="/snap/snapcraft/current"
ENV SNAP_NAME="snapcraft"
ENV SNAP_ARCH="amd64"
