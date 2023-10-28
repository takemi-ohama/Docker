FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git vim wget mysql-client ssh libreadline-dev curl \
    ca-certificates sudo unzip locales language-pack-ja-base language-pack-ja \
    libpq-dev build-essential  fonts-ipaexfont fonts-ipafont \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ARG PYTHON_VERSION=3.10
ARG O_USER="sagemaker-user"
ARG O_UID="1000"
ARG O_GID="1000"
ARG CONDA_DIR=/opt/conda
ARG PYTHONPATH=/home/${O_USER}/SageMaker/mllib

ENV SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PYTHONUNBUFFERED=TRUE \
    PYTHONDONTWRITEBYTECODE=TRUE \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    VISIBLE=now \
    PATH=${CONDA_DIR}/bin:${PATH}


RUN groupadd -g ${O_GID} $O_USER && useradd --uid ${O_UID} --gid ${O_GID} -m -s /bin/bash $O_USER && \
    usermod -aG users $O_USER && \
    usermod -aG users root && \
    echo '%users ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /home/$O_USER/.ssh && chown $O_USER.$O_USER /home/$O_USER/.ssh && \
    mkdir -p ${CONDA_DIR} && \
    chown -R $O_USER:users ${CONDA_DIR} && \
    find ${CONDA_DIR} -type d -print0 | xargs -0 chmod g+s

# vscode serverのインストール
RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | sh

# aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

USER $O_USER
WORKDIR /home/$O_USER

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
    mamba clean --all -f -y

COPY --chown=${O_USER}:users requirements.txt requirements.txt
COPY --chown=${O_USER}:users conda.txt conda.txt

RUN pip install -U pip
RUN mamba install -y --file conda.txt && mamba clean --all -f -y
#RUN pip uninstall -y torch
RUN pip install  --no-cache-dir -r requirements.txt


ENV PYTHONPATH=${PYTHONPATH}
CMD tail -f /dev/null
