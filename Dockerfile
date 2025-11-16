FROM ubuntu:latest

ARG RUNNER_VERSION="2.329.0"
ARG TARGETARCH=x64
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_AS_ROOT=true

RUN apt update && apt install --yes \
    curl git jq sudo unzip \
    docker.io \
    build-essential libssl-dev zlib1g-dev libffi-dev libicu-dev \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --gid docker docker && \
    usermod --append --groups sudo docker && \
    echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER docker
WORKDIR /home/docker

# Install GitHub Actions Runner script
RUN curl --remote-name --location https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz && \
    rm ./actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz

# Install Rust & Cargo
RUN curl --silent --show-error --fail --location https://sh.rustup.rs --output rustup-init.sh \
    && chmod +x rustup-init.sh \
    && bash rustup-init.sh -y \
    && rm rustup-init.sh \
    && echo 'source $HOME/.cargo/env' >> ~/.bashrc

COPY entrypoint.sh .
RUN sudo chmod +x entrypoint.sh
ENTRYPOINT [ "/home/docker/entrypoint.sh" ]
