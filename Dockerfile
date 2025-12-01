# Usa o Ubuntu 24.04 (Noble Numbat) como base
FROM ubuntu:24.04

# Configuração de Variáveis de Ambiente para o Java
ENV JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin


RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        cron \
        openjdk-25-jdk \
        wget \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuração do SSH
RUN mkdir /var/run/sshd
# Cria o usuário 'devuser' com a senha 'mypassword'
RUN useradd -ms /bin/bash devuser
RUN echo 'devuser:mypassword' | chpasswd
# Permite o login de root (para fins de debug/ensino, embora em produção não seja ideal)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# A linha abaixo corrige um bug de login em ambientes Docker com SSH
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Configure SSH to listen on port 2222 inside the container (avoid using host port 22)
RUN sed -i 's/^#Port 22/Port 2224/' /etc/ssh/sshd_config || echo 'Port 2224' >> /etc/ssh/sshd_config

# Define o diretório de trabalho do usuário
WORKDIR /home/devuser

# Exponha a porta 2222 para SSH (o Compose fará o mapeamento para uma porta do host)
EXPOSE 2224

# Inicia o serviço SSH e o cron quando o container for iniciado
CMD service cron start && /usr/sbin/sshd -D

