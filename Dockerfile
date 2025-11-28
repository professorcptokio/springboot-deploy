# Usa o Ubuntu 24.04 (Noble Numbat) como base
FROM ubuntu:24.04

# Configuração de Variáveis de Ambiente para o Java
ENV JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

# 1. Atualiza e instala os pacotes necessários
# openjdk-21-jdk: Substitui o Java 25 pelo Java 21 LTS (versão moderna e estável)
# openssh-server: Permite a conexão remota (simulação de deploy)
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        openjdk-21-jdk \
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

# Define o diretório de trabalho do usuário
WORKDIR /home/devuser

# Exponha a porta 22 para SSH (o Compose fará o mapeamento 2222:22)
EXPOSE 22

# Comando principal: Inicia o servidor SSH em modo daemon (foreground)
CMD ["/usr/sbin/sshd", "-D"]