FROM ubuntu:jammy

LABEL mantainer="Manprint"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
	&& apt upgrade -y \
	&& apt install -y ca-certificates supervisor unzip \
		sudo nano curl wget tree make git bash-completion \
		telnet iputils-ping tzdata htop gnupg net-tools \
		apt-utils locales openssl software-properties-common \
	&& ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime \
	&& dpkg-reconfigure -f noninteractive tzdata \
	&& curl -fsSL https://get.docker.com -o get-docker.sh \
	&& sh get-docker.sh && rm -f get-docker.sh \
	&& addgroup --gid 1000 ubuntu \
	&& useradd -m -s /bin/bash -g ubuntu -G sudo,root,docker -u 1000 ubuntu \
	&& echo "ubuntu:ubuntu" | chpasswd && echo "root:root" | chpasswd \
	&& echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
	&& curl -O https://releases.hashicorp.com/terraform/1.2.3/terraform_1.2.3_linux_amd64.zip \
	&& unzip terraform_1.2.3_linux_amd64.zip && mv terraform /usr/bin/ \
	&& chmod +x /usr/bin/terraform && rm -f terraform_1.2.3_linux_amd64.zip \
	&& apt-get clean \
	&& apt-get autoremove -y \
	&& apt-get autoclean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN --mount=type=bind,target=/tmp/context \
	mkdir -p /etc/supervisor/conf.d/ \
	&& cp -a /tmp/context/assets/supervisor/supervisord.conf /etc/supervisor/conf.d/ \
	&& mkdir -vp /etc/docker/ \
	&& cp -a /tmp/context/assets/daemon.json /etc/docker/ \
	&& cp -a /tmp/context/assets/entrypoint.sh / \
	&& rm -f /home/ubuntu/.bash_profile /home/ubuntu/.bashrc \
	&& cp -a /tmp/context/assets/bashrc/.bashrc /home/ubuntu \
	&& cp -a /tmp/context/assets/bashrc/.bash_profile /home/ubuntu \
	&& chown -R ubuntu:ubuntu /home/ubuntu \
	&& rm -f /root/.bash_profile /root/.bashrc \
	&& cp -a /tmp/context/assets/bashrc/.bashrc /root \
	&& cp -a /tmp/context/assets/bashrc/.bash_profile /root \
	&& cp -a /tmp/context/assets/supervisor/start-services.sh /etc/supervisor/conf.d \
	&& cp -a /tmp/context/assets/override.conf /etc/systemd/system/docker.service.d

USER ubuntu

WORKDIR /home/ubuntu

VOLUME [ "/var/lib/docker", "/home/ubuntu" ]

EXPOSE 2375

CMD ["sudo", "/entrypoint.sh"]
