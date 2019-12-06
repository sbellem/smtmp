FROM sbellem/scale-mamba-deps:latest

# CONFIG
ENV MPC_HOME /usr/src/SCALE-MAMBA
WORKDIR $MPC_HOME
COPY . .
COPY CONFIG CONFIG.mine
RUN echo "ROOT = ${MPC_HOME}" >> CONFIG.mine
RUN echo "OSSL = ${DEPS_HOME}/openssl" >> CONFIG.mine

# build
RUN make progs
RUN make test

# For sphinx-based docs
ARG BUILD
RUN if [ "$BUILD" = "doc" ]; \
        pip install --upgrade pip sphinx sphinx_rtd_theme
    fi

# For development
RUN if [ "$BUILD" = "dev" ]; \
        pip install --upgrade pip sphinx sphinx_rtd_theme ipython
    fi
