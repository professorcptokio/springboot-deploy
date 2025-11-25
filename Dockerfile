FROM ubuntu:24.04
ENV JAVA_HOME /usr/lib/jvm/jdk-25
ENV PATH $PATH:$JAVA_HOME/bin

RUN apt-get update && apt-get install -y \
    openssh-server \
    openjdk-25-jdk \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
# Cria o usuário 'devuser' com a senha 'mypassword'
RUN useradd -ms /bin/bash devuser
RUN echo 'devuser:mypassword' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]