ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION

# Again here as it is consumed by the above FROM statement
ARG UBUNTU_VERSION=22.04

# Update the system
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

# Install base tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
                    ca-certificates \
                    lsb-release \
                    curl \
                    sudo \
                    less \
                    htop \
                    nano \
                    git

# Install tools for classic make toolchain
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
                    build-essential \
                    ccache \
                    flex \
                    bison

# Install dependencies for qemu build
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
                    libiscsi-dev \
                    libaio-dev \
                    libnfs-dev \
                    librbd-dev \
                    libglib2.0-dev \
                    libnuma-dev \
                    libslirp-dev \
                    libpixman-1-dev \
                    libsnappy-dev \
                    libfdt-dev \
                    librdmacm-dev \
                    libibverbs-dev \
                    libvdeplug-dev \
                    libgtk-3-dev \
                    libvte-2.91-dev \
                    libbrlapi-dev \
                    libxen-dev \
                    valgrind \
                    libcap-ng-dev \
                    libcurl4-gnutls-dev \
                    libncurses5-dev \
                    libseccomp-dev \
                    libsdl1.2-dev \
                    libsasl2-dev \
                    liblzo2-dev \
                    libssh-dev \
                    git \
                    python-is-python3 \
                    python3-pip \
                    python3-tomli \
                    ninja-build

# Setup ccache
RUN /usr/sbin/update-ccache-symlinks

# Setup history search using Page-Up/Page-Down
RUN sed -i -E 's/# (.* history-search-.*)/\1/g' /etc/inputrc

# Create the 'dev' user
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Persist bash history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/bash_history/.bash_history" \
    && mkdir /bash_history \
    && touch /bash_history/.bash_history \
    && chown -R $USERNAME /bash_history \
    && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

# Use the 'dev' user in this container
USER $USERNAME
ENV USER=$USERNAME
