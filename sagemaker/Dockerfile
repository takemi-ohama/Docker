# syntax=docker/dockerfile:1
FROM nvidia/cuda:12.9.0-cudnn-devel-ubuntu24.04 as base

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git vim wget mysql-client ssh libreadline-dev curl \
    ca-certificates sudo unzip locales language-pack-ja-base language-pack-ja \
    libpq-dev build-essential  fonts-ipaexfont fonts-ipafont \
    apt-transport-https bzip2 gnupg

#google cloud cli
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update -y && apt-get install google-cloud-sdk -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# vscode serverのインストール
RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | sh

# aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# docker
RUN curl https://get.docker.com | sudo sh

ARG O_USER="sagemaker-user" \
    O_UID="1000" \
    CONDA_DIR=/opt/conda \
    PYTHON_VERSION=3.12.10 \
    CONDA_OVERRIDE_CUDA=12.9

ENV SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PYTHONUNBUFFERED=TRUE \
    PYTHONDONTWRITEBYTECODE=TRUE \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    VISIBLE=now \
    PATH=${CONDA_DIR}/bin:${PATH} \
    PYTHONPATH=/home/${O_USER}/SageMaker/mllib:/home/${O_USER}/user-default-efs/SageMaker/mllib \
    HF_HOME=/home/${O_USER}/.cache/huggingface \
    DOCKER_ARCH="$(uname)-$(uname -m)"

#ubuntuユーザを削除
RUN deluser --remove-home ubuntu

#ユーザを作成
RUN useradd --uid ${O_UID} -m -s /bin/bash $O_USER && \
    usermod -aG users $O_USER && \
    usermod -aG users root && \
    echo '%users ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /home/$O_USER/.ssh && chown $O_USER.$O_USER /home/$O_USER/.ssh && \
    mkdir -p ${CONDA_DIR} && \
    chown -R $O_USER:users ${CONDA_DIR} && \
    find ${CONDA_DIR} -type d -print0 | xargs -0 chmod g+s && \
    git config --global credential.helper store

USER $O_USER
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
    conda config --system --set show_channel_urls true

RUN mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba install --quiet --yes mamba conda && \
    mamba update --all --quiet --yes && \
    mamba clean --all -y

WORKDIR /home/$O_USER

COPY --chown=${O_USER}:users conda.txt conda.txt
RUN mamba install -y  --file conda.txt

COPY --chown=${O_USER}:users cuda.txt cuda.txt
RUN mamba install -y  --file cuda.txt

COPY --chown=${O_USER}:users requirements.txt requirements.txt
RUN pip install  -U pip
RUN pip install  --no-cache-dir -r requirements.txt
RUN pip install flash-attn --no-build-isolation && \
    mamba clean --all -y && pip cache purge

# SageMaker Studio用の設定
USER root
RUN mkdir -p /home/backup && \
    chown -R $O_USER:users /home/backup

USER $O_USER
COPY --chown=${O_USER}:users user_root/.jupyter /home/backup/.jupyter

WORKDIR /home/$O_USER
RUN cp -a .profile /home/backup && \
    cp -a .bashrc /home/backup && \
    ln -s /home/$O_USER/user-default-efs/SageMaker /home/backup/SageMaker

FROM base as jupyter

RUN python -m bash_kernel.install

CMD jupyter lab --ip 0.0.0.0 --port 8888 \
    --ServerApp.base_url="/jupyterlab/default" \
    --ServerApp.token='' \
    --ServerApp.allow_origin='*'

FROM base as codeeditor

CMD sagemaker-code-editor --host 0.0.0.0 --port 8888 \
    --without-connection-token \
    --base-path "/codeeditor/default"




