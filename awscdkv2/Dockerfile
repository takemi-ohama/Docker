FROM ubuntu:jammy

LABEL MAINTAINER takemi.ohama<takemi.ohama@gmail.com>

ARG USERNAME="docker"
ARG UID="1000"
ARG CONDA_DIR="/home/${USERNAME}/conda"
ARG PYTHON_VERSION=3.11.6

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git vim wget mysql-client ssh libreadline-dev curl \
    ca-certificates sudo unzip bzip2 gnupg\
    locales language-pack-ja-base language-pack-ja \
    nodejs npm jq peco apt-transport-https

#google cloud cli
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
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
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN npm install -g n && n 20.9.0
RUN npm install -g npm && npm -g update
RUN npm install -g \
    aws-cdk aws-cdk-lib typescript \
    && npm cache clean --force

# aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# ssm manager plugin
RUN if test "`uname -m`" = "x86_64" ; then arch=64bit; else arch=arm64; fi && \
    echo ${arch} && curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${arch}/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    rm -f session-manager-plugin.deb

# sssh script
# https://github.com/pj8/sssh
RUN curl "https://raw.githubusercontent.com/pj8/sssh/main/sssh" -o "/usr/local/bin/sssh" && \
    chmod 755 /usr/local/bin/sssh

USER ${USERNAME}
WORKDIR /tmp
SHELL ["/bin/bash","-c"]

RUN set -x && \
    miniforge_installer="Miniforge3-$(uname)-$(uname -m).sh" && \
    wget -q https://github.com/conda-forge/miniforge/releases/latest/download/${miniforge_installer} && \
    /bin/bash "${miniforge_installer}" -f -b -p "${CONDA_DIR}" && \
    rm "${miniforge_installer}" && \
    source "${CONDA_DIR}/etc/profile.d/conda.sh" && \
    source "${CONDA_DIR}/etc/profile.d/mamba.sh" && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    mamba install --quiet --yes python~="${PYTHON_VERSION}" && \
    mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba install --quiet --yes mamba conda && \
    mamba update --all --quiet --yes && \
    conda clean --all -y  #manba clean

RUN mamba install -y python-dotenv autopep8 pytest pydantic pandas boto3 pyyaml
RUN pip install aws-cdk-lib constructs cdk-remote-stack
RUN conda clean --all -y && pip cache purge

RUN git config --global credential.helper store

WORKDIR /home/docker
