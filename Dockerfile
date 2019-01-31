FROM ubuntu:bionic

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get dist-upgrade --yes && \
  apt-get install --yes curl sudo jq squashfs-tools tzdata && \
  curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core' | jq '.download_url' -r) --output core.snap && \
  mkdir -p /snap/core && unsquashfs -d /snap/core/current core.snap && rm core.snap && \
  curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core18' | jq '.download_url' -r) --output core18.snap && \
  mkdir -p /snap/core18 && unsquashfs -d /snap/core18/current core18.snap && rm core18.snap && \
  curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/snapcraft?channel=candidate' | jq '.download_url' -r) --output snapcraft.snap && \
  mkdir -p /snap/snapcraft && unsquashfs -d /snap/snapcraft/current snapcraft.snap && rm snapcraft.snap && \
  sed -i.back -e 's|installed_snaps =|installed_snaps = [] #|g' /snap/snapcraft/current/lib/python*/site-packages/snapcraft/internal/lifecycle/_runner.py && \
  sed -i.back -e 's|if not repo.snaps.SnapPackage.is_snap_installed(project.info.base):|True|g' /snap/snapcraft/current/lib/python3.5/site-packages/snapcraft/internal/project_loader/_config.py && \
  sed -i.back -e 's|    self.build_snaps.add||g' /snap/snapcraft/current/lib/python3.5/site-packages/snapcraft/internal/project_loader/_config.py && \
  curl -L https://raw.githubusercontent.com/snapcore/snapcraft/master/docker/bin/snapcraft-wrapper --output snapcraft-wrapper && \
  mkdir -p /snap/bin && \
  mv snapcraft-wrapper /snap/bin/snapcraft && \
  chmod a+x /snap/bin/snapcraft && \
  apt remove --yes --purge curl jq squashfs-tools && \
  apt-get autoclean --yes && \
  apt-get clean --yes

ENV PATH=/snap/bin:$PATH
