FROM python:2-buster

# dependencies
RUN apt-get update && apt-get install -y yasm libmpc-dev doxygen psmisc
RUN pip install --upgrade pip gmpy2 networkx

ENV DEPS_HOME /usr/src

# install MPIR 3.0.0
WORKDIR /tmp/
RUN curl -O http://mpir.org/mpir-3.0.0.tar.bz2
RUN tar xf mpir-3.0.0.tar.bz2
WORKDIR /tmp/mpir-3.0.0/
RUN ./configure --enable-cxx --prefix="${DEPS_HOME}/mpir"
RUN make && make check && make install

# install OpenSSL 1.1.0
WORKDIR /tmp/
RUN curl -O https://www.openssl.org/source/openssl-1.1.0j.tar.gz
RUN tar -xf openssl-1.1.0j.tar.gz
WORKDIR /tmp/openssl-1.1.0j
RUN ./config --prefix="${DEPS_HOME}/openssl"
RUN make && make install

# install crypto++
WORKDIR /tmp/
ENV CRYPTOPP_VERSION cryptopp700
RUN curl -O https://www.cryptopp.com/${CRYPTOPP_VERSION}.zip
RUN unzip ${CRYPTOPP_VERSION}.zip -d ${CRYPTOPP_VERSION}
WORKDIR /tmp/${CRYPTOPP_VERSION}
RUN make && make install PREFIX="${DEPS_HOME}/cryptopp"

# ENV MPIR paths
ENV PATH "${DEPS_HOME}/mpir/bin/:${PATH}"
ENV C_INCLUDE_PATH "${DEPS_HOME}/mpir/include/:${C_INCLUDE_PATH}"
ENV CPLUS_INCLUDE_PATH "${DEPS_HOME}/mpir/include/:${CPLUS_INCLUDE_PATH}"
ENV LIBRARY_PATH "${DEPS_HOME}/mpir/lib/:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH "${DEPS_HOME}/mpir/lib/:${LD_LIBRARY_PATH}"

# ENV OpenSSL paths
ENV PATH "${DEPS_HOME}/openssl/bin/:${PATH}"
ENV C_INCLUDE_PATH "${DEPS_HOME}/openssl/include/:${C_INCLUDE_PATH}"
ENV CPLUS_INCLUDE_PATH "${DEPS_HOME}/openssl/include/:${CPLUS_INCLUDE_PATH}"
ENV LIBRARY_PATH "${DEPS_HOME}/openssl/lib/:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH "${DEPS_HOME}/openssl/lib/:${LD_LIBRARY_PATH}"

# export Crypto++ paths
ENV CPLUS_INCLUDE_PATH "${DEPS_HOME}/cryptopp/include/:${CPLUS_INCLUDE_PATH}"
ENV LIBRARY_PATH "${DEPS_HOME}/cryptopp/lib/:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH "${DEPS_HOME}/cryptopp/lib/:${LD_LIBRARY_PATH}"
