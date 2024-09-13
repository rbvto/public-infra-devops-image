FROM debian:12
ENV DEBIAN_FRONTEND=noninteractive

USER root

WORKDIR /app

RUN export ARCH=$(dpkg --print-architecture) \
&& apt-get update -qq -y \
&& apt-get install -qq -y ca-certificates \
&&  echo "deb [arch=${ARCH} trusted=yes] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list \
&&  apt-get update -qq -y \
&&  apt-get install -qq -y \
                  jq \
                  git \
                  zip \
                  pipx \
                  curl \
                  bash \
                  make \
                  gnupg \
                  openssl \
                  ca-certificates \
                  docker-ce \
                  docker-ce-cli \
                  containerd.io \
                  docker-buildx-plugin \
                  docker-compose-plugin \
                  python3-pip \
                  python3-apt \
                  python3-distutils \
&&  apt-get autoclean -y \
&&  apt-get autoremove -y

RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ./tfenv \
&&  chmod +x ./tfenv/bin/* \
&&  ln -s /app/tfenv/bin/* /usr/local/bin

RUN git clone --depth=1 https://github.com/cunymatthieu/tgenv.git ./tgenv \
&&  chmod +x ./tgenv/bin/* \
&&  ln -s /app/tgenv/bin/* /usr/local/bin

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
&&  unzip awscliv2.zip \
&&  ./aws/install

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENV N_PREFIX=/app/n
RUN curl -L https://bit.ly/n-install | bash -s -- -y
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/app/n/bin:/root/.local/bin

RUN export ARCH=$(dpkg --print-architecture) \
&&  export SYSTEM=$(uname | tr '[:upper:]' '[:lower:]' ) \
&&  curl -s https://api.github.com/repos/little-angry-clouds/kubernetes-binaries-managers/releases/latest \
| jq -r '.assets[] | select(.browser_download_url | contains ("'${SYSTEM}_${ARCH}'")) | .browser_download_url' \
| xargs curl -s -L -o kbenv.tar.gz \
&&  tar -zxvf kbenv.tar.gz \
&&  mv kubectl-${SYSTEM}-${ARCH}/kbenv /usr/bin/kbenv \
&&  mv kubectl-${SYSTEM}-${ARCH}/kubectl-wrapper /usr/bin/kubectl \
&&  mv helm-${SYSTEM}-${ARCH}/helmenv /usr/bin/helmenv \
&&  mv helm-${SYSTEM}-${ARCH}/helm-wrapper /usr/bin/helm

ENV KUBECTL_VERSION=1.28.2
ENV HELM_VERSION=3.15.4
RUN kbenv install ${KUBECTL_VERSION} \
&&  kbenv use ${KUBECTL_VERSION} \
&&  helmenv install ${HELM_VERSION} \
&&  helmenv use ${HELM_VERSION}

ENV TF_VERSION=1.9.5
RUN tfenv install ${TF_VERSION} \
&&  tfenv use ${TF_VERSION}

ENV TG_VERSION=0.56.5
RUN tgenv install ${TG_VERSION} \
&&  tgenv use ${TG_VERSION}

ENV ANSIBLE_VERSION=10.4.0
RUN pipx install ansible==${ANSIBLE_VERSION}
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/app/n/bin:/root/.local/bin:/root/.local/pipx/venvs/ansible/bin

COPY rootfs/ /
