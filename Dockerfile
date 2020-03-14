# Mesa3D Software Drivers

FROM ubuntu:18.04 as builder

# Install all needed build deps for Mesa
RUN set -xe; apt-get update
RUN set -xe; \
    apt-get -y install \
        pkg-config \
        autoconf \
        automake \
        bison \
        binutils \
        gcc \
        make \
        libc-dev \
        g++ \
        libexpat-dev \
        flex \
        gettext \
        git \
        libgl-dev \
        libglu-dev \
        libtool \
        llvm-7 \
        llvm-7-dev \
        llvm-7-tools \
        libllvm7 \
        python-mako \
        python3-mako \
        xserver-xorg-dev \
        python3-dev \
        python-dev \
        zlib1g-dev;

# Clone Mesa source repo. (this step caches)
# Due to ongoing packaging issues we build from git vs tar packages
# Refer to https://bugs.freedesktop.org/show_bug.cgi?id=107865
RUN set -xe; \
    mkdir -p /var/tmp/build; \
    cd /var/tmp/build; \
    git clone https://gitlab.freedesktop.org/mesa/mesa.git;

# Build Mesa from source.
#RUN which llvm-config
RUN /usr/lib/llvm-7/bin/llvm-config --version
ARG MESA_VERSION
RUN set -xe; \
#    PATH=/usr/lib/llvm-7/bin/llvm-config:$PATH; \
    cd /var/tmp/build/mesa; \
    git checkout mesa-${MESA_VERSION}; \
    libtoolize; \
    AL_OPTS=-I/usr/share/aclocal autoreconf --install; \
    ./configure \
        --enable-glx=gallium-xlib \
        --with-gallium-drivers=swrast,swr \
        --disable-dri \
        --disable-gbm \
        --disable-egl \
        --enable-gallium-osmesa \
        --enable-autotools \
        --enable-llvm \
        --with-llvm-prefix=/usr/lib/llvm-7/ \
        --prefix=/usr/local; \
    make -j$(getconf _NPROCESSORS_ONLN); \
    make install;

# Copy our entrypoint into the container.
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# Create fresh image from alpine
FROM ubuntu:18.04

# Install runtime dependencies for Mesa
RUN set -xe; apt-get update
RUN set -xe; \
    apt-get -y install \
        libexpat-dev \
        libllvm7 \
        x11-utils \
        xvfb \
        python3-dev \
        python3-pip \
        libxcursor1 \
        libasound2 \
        libpulse0 \
        psmisc \
        nano \
        less;
RUN set -xe; apt-get -y upgrade

# Copy the Mesa build & entrypoint script from previous stage
COPY --from=builder /usr/local /usr/local

# Labels / Metadata.
ARG VCS_REF
ARG BUILD_DATE
ARG MESA_DEMOS
ARG MESA_VERSION
LABEL maintainer="Robin Åstedt, robin.astedt@gmail.com" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.decription="Mesa3D Software Drivers" \
      org.label-schema.name="Mesa3D-Software-Drivers" \
      org.label-schema.schema-version="1.0.0-rc1" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/robinastedt/docker-opengl" \
      org.label-schema.vendor="Robin Åstedt" \
      org.label-schema.version="${MESA_VERSION}"

# Setup our environment variables.
ENV DISPLAY=":99" \
    GALLIUM_DRIVER="llvmpipe" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    LP_DEBUG="" \
    LP_NO_RAST="false" \
    LP_NUM_THREADS="" \
    LP_PERF="" \
    MESA_VERSION="${MESA_VERSION}" \
    XVFB_WHD="1920x1080x24"

# Set the default command.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
