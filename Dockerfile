FROM debian:12
ENV DEBIAN_FRONTEND=noninteractive

USER root

WORKDIR /app

COPY rootfs/ /

RUN apt update -qq -y >/dev/null 2>&1 \
&&  apt install -qq -y \
                  jq \
                  git \
                  zip \
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
&&  apt autoclean -y \
&&  apt autoremove -y \
&&  rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ./tfenv \
&&  chmod +x ./tfenv/bin/* \
&&  mv ./tfenv/bin/* /usr/local/bin

RUN git clone --depth=1 https://github.com/cunymatthieu/tgenv.git ./tgenv \
&&  chmod +x ./tgenv/bin/* \
&&  mv ./tgenv/bin/* /usr/local/bin

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
&&  unzip awscliv2.zip \
&&  ./aws/install

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENV N_PREFIX=/app/n
RUN curl -L https://bit.ly/n-install | bash -s -- -y
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/app/n/bin


RUN curl -s https://api.github.com/repos/little-angry-clouds/kubernetes-binaries-managers/releases/latest \
| jq -r '.assets[] | select(.browser_download_url | contains ("linux_amd64")) | .browser_download_url' \
| xargs curl -sLo kbenv.tar.gz \
&&  tar -zxvf kbenv.tar.gz \
&&  mv kubectl-linux-amd64/kbenv /usr/bin/kbenv \
&&  mv kubectl-linux-amd64/kubectl-wrapper /usr/bin/kubectl \
&&  mv helm-linux-amd64/helmenv /usr/bin/helmenv \
&&  mv helm-linux-amd64/helm-wrapper /usr/bin/helm

ENV KUBECTL_VERSION=1.28.2
ENV HELM_VERSION=3.15.4
RUN /usr/bin/kbenv install ${KUBECTL_VERSION} \
&&  /usr/bin/kbenv use ${KUBECTL_VERSION} \
&&  /usr/bin/helmenv install ${HELM_VERSION} \
&&  /usr/bin/helmenv use ${HELM_VERSION}

ENV TF_VERSION=1.9.5
RUN tfenv install ${TF_VERSION} \
&&  tfenv use ${TF_VERSION}

ENV TG_VERSION=0.56.5
RUN tgenv install ${TG_VERSION} \
&&  tgenv use ${TG_VERSION}

ENV ANSIBLE_VERSION=10.4.0
RUN pip3 install ansible==${ANSIBLE_VERSION}

