FROM ubuntu:jammy

LABEL MAINTAINER takemi.ohama<takemi.ohama@gmail.com>

ARG USERNAME="docker"
ARG UID="1000"
ARG CONDA_DIR="/opt/conda"
ARG PYTHON_VERSION=3.11.6

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git vim wget mysql-client ssh libreadline-dev curl \
    ca-certificates sudo unzip locales language-pack-ja-base language-pack-ja \
    nodejs npm unzip jq peco apt-transport-https gnupg

#google cloud cli
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update -y && apt-get install google-cloud-sdk -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*



RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PYTHONUNBUFFERED=TRUE \
    PYTHONDONTWRITEBYTECODE=TRUE \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    VISIBLE=now \
    PATH=${CONDA_DIR}/bin:${PATH}

RUN useradd --uid ${UID} -m -s /bin/bash -G sudo,www-data,users ${USERNAME} && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir -p ${CONDA_DIR} && \
    chown -R ${UID}:users ${CONDA_DIR} && \
    find ${CONDA_DIR} -type d -print0 | xargs -0 chmod g+s

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN set -x && \
    miniforge_installer="Mambaforge-Linux-$(uname -m).sh" && \
    wget -q https://github.com/conda-forge/miniforge/releases/latest/download/${miniforge_installer} && \
    /bin/bash "${miniforge_installer}" -f -b -p "${CONDA_DIR}" && \
    rm "${miniforge_installer}" && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    mamba install --quiet --yes python~="${PYTHON_VERSION}" && \
    mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba install --quiet --yes mamba && \
    mamba update --all --quiet --yes && \
    mamba clean --all -f -y

RUN npm install -g n && n 20.9.0
RUN npm install -g npm && npm -g update
RUN npm install -g \
    aws-cdk aws-cdk-lib typescript \
    && npm cache clean --force

# aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# ssm manager plugin
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    rm -f session-manager-plugin.deb

# sssh script
# https://github.com/pj8/sssh
RUN curl "https://raw.githubusercontent.com/pj8/sssh/main/sssh" -o "/usr/local/bin/sssh" && \
    chmod 755 /usr/local/bin/sssh

USER docker
WORKDIR /home/docker

RUN mamba install -y python-dotenv autopep8 pytest pydantic pandas boto3 pyyaml

RUN pip install aws-cdk-lib constructs cdk-remote-stack

RUN git config --global credential.helper store
