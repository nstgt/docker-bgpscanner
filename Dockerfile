FROM debian:9.7 as builder
RUN apt update \
    && apt install -y git cmake ninja-build pkg-config python3-pip zlib1g-dev libbz2-dev liblzma-dev liblz4-dev
RUN pip3 install meson
RUN git clone https://gitlab.com/Isolario/bgpscanner.git /root/bgpscanner \
    && mkdir /root/bgpscanner/build
WORKDIR /root/bgpscanner/build
RUN /usr/local/bin/meson --buildtype=release ..
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/bgpscanner/build/./subprojects/isocore \
    && ldconfig
RUN ninja install

FROM debian:9.7-slim
WORKDIR /root
COPY --from=builder /usr/local/bin/bgpscanner /usr/local/bin/bgpscanner
COPY --from=builder /root/bgpscanner/build/./subprojects/isocore/libisocore.so /usr/local/lib
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
