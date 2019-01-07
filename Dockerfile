FROM ubuntu:latest

RUN apt update && \
  apt upgrade -y && \
  apt install -y automake bc build-essential bzip2 ccache curl dpkg-dev git gperf \
  libghc-bzlib-dev libncurses-dev libz-dev libssl-dev liblz4-tool \
  make pngquant python-networkx schedtool squashfs-tools zlib1g && \
  apt clean

RUN mkdir /toolchains && cd /toolchains && \
  git clone https://github.com/bdashore3/aarch64-gcc aarch64-gcc && \
  git clone https://github.com/bdashore3/gcc-arm arm-gcc && \
  git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r346389b clang && \
  git clone https://android.googlesource.com/platform/external/lz4 lz4

ENV USE_CCACHE=1
ENV ANDROID_JACK_VM_ARGS="-Xmx11g -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

WORKDIR /src

CMD ["bash", "-c", "set -o allexport && ./compile.sh"]
