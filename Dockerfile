FROM ubuntu:18.04 AS yosys-builder
LABEL maintainer="andrsmllr <andrsmllr@bananatronics.org>"
LABEL description="SymbiYosys open source formal verification toolkit"
LABEL version="1.0"
#ARG YOSYS_VERSION=

ENV TERM xterm-256color
VOLUME /workdir
WORKDIR /workdir

# Get Yosys sources dependencies.
# tzdata will prompt for user input during installation. Suppress this with the following ENV.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -qq \
    && apt install -qq -y \
      build-essential \
      clang \
      bison \
      flex \
      libreadline-dev \
      gawk \
      tcl-dev \
      libffi-dev \
      git \
      mercurial \
      graphviz \
      xdot \
      pkg-config \
      python \
      python3 \
      libftdi-dev \
      gperf \
      libboost-program-options-dev \
      autoconf \
      libgmp-dev \
      cmake \
      wget

ENV YOSYS_SRC /usr/src/yosys
RUN git clone https://github.com/YosysHQ/yosys.git ${YOSYS_SRC}
WORKDIR ${YOSYS_SRC}
RUN make -j$(nproc)
RUN make install

ENV SBY_SRC /usr/src/symbiyosys
RUN git clone https://github.com/YosysHQ/SymbiYosys.git ${SBY_SRC}
WORKDIR ${SBY_SRC}
RUN make install

ENV YICES2_SRC /usr/src/yices2
RUN git clone https://github.com/SRI-CSL/yices2.git ${YICES2_SRC}
WORKDIR ${YICES2_SRC}
RUN autoconf && ./configure
RUN make -j$(nproc)
RUN make install

ENV Z3_SRC /usr/src/z3
RUN git clone https://github.com/Z3Prover/z3.git ${Z3_SRC}
WORKDIR ${Z3_SRC}
RUN python ./scripts/mk_make.py
WORKDIR ${Z3_SRC}/build
RUN make -j$(nproc)
RUN make install

ENV SPRPRV_SRC /usr/local/superprove
RUN mkdir ${SPRPRV_SRC}
WORKDIR ${SPRPRV_SRC}
RUN wget http://downloads.bvsrc.org/super_prove/super_prove-hwmcc17_final-2-d7b71160dddb-Ubuntu_14.04-Release.tar.gz
RUN tar xf $(find . -name "super_prove*.tar.gz")
ENV SPRPRV_WRAPPER /usr/local/bin/superprove
RUN echo '#!/bin/bash' >> ${SPRPRV_WRAPPER}; \
    echo 'tool=super_prove; if [ "$1" != "${1$#+}" ]; then tool="${1#+}"; shift; fi' >> ${SPRPRV_WRAPPER} \
    echo 'exec /usr/local/super_prove/bin/${tool}.sh "$@"' >> ${SPRPRV_WRAPPER}

ENV AVY_SRC /usr/src/avy
RUN git clone https://bitbucket.org/arieg/extavy.git ${AVY_SRC}
WORKDIR ${AVY_SRC}
RUN git submodule update --init --recursive \
    && mkdir -p ${AVY_SRC}/build 
WORKDIR ${AVY_SRC}/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make -j$(nproc)
RUN cp ./avy/src/avy /usr/local/bin \
    && cp ./avy/src/avybmc /usr/local/bin

ENV BOOLECTOR_SRC /usr/src/boolector
RUN git clone https://github.com/boolector/boolector ${BOOLECTOR_SRC}
WORKDIR ${BOOLECTOR_SRC}
RUN ./contrib/setup-btor2tools.sh \
    && ./contrib/setup-lingeling.sh \
    && ./configure.sh
RUN make -C build -j$(nproc)
RUN cp build/bin/boolector /usr/local/bin \
    && cp build/bin/btor* /usr/local/bin \
    && cp deps/btor2tools/bin/btorsim /usr/local/bin

ENTRYPOINT ["/usr/local/bin/sby"]
CMD ["--help"]
