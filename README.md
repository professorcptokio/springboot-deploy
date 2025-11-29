# springboot-deploy

**Overview**
- **Descrição:** Repositório de exemplo para simular deploy de uma aplicação Spring Boot via SSH em um container, com um serviço MySQL em outro container.

**Pré-requisitos**
- **Docker & Docker Compose:** instalados localmente.
- **Java / Maven (opcional):** necessário apenas para rebuildar o artefato localmente.

**Comandos Úteis**
- **Instalar JDK (SDKMAN)**: instalar Java localmente (ex.: Java 25):
```bash
# Exemplo com SDKMAN
# sdk install java 25-open
```

- **Subir a stack (build + up)**: constrói imagens e sobe os serviços definidos em `docker-compose.yml`.
```bash
docker compose up -d --build
```

- **Reconstruir apenas um serviço (no-cache)**: forçar rebuild do serviço `ssh_java_server`.
```bash
docker compose build --no-cache ssh_java_server
docker compose up -d --force-recreate ssh_java_server
```

- **Remover chave antiga do known_hosts (SSH)**: útil quando a chave do host mudou.
```bash
ssh-keygen -f ~/.ssh/known_hosts -R '[localhost]:2222'
```

- **Copiar o JAR para o container via SCP (porta 2222)**: lembre-se de usar `-P` maiúsculo para porta.
```bash
scp -P 2222 ./demobatch/target/demobatch-0.0.1-SNAPSHOT.jar devuser@localhost:/home/devuser
```

- **Conectar via SSH ao container (porta 2222)**:
```bash
ssh devuser@localhost -p 2222
```

- **Executar o JAR dentro do container (inline)**: mostra logs no terminal.
```bash
docker exec -it remote-deploy-server java -jar /home/devuser/demobatch-0.0.1-SNAPSHOT.jar
```

- **Executar o JAR em background dentro do container** (redireciona output para `app.log`):
```bash
docker exec -it remote-deploy-server bash -lc "nohup java -jar /home/devuser/demobatch-0.0.1-SNAPSHOT.jar > /home/devuser/app.log 2>&1 &"
```

- **Ver status dos containers**:
```bash
docker ps
```

- **Ver logs de um container**:
```bash
docker logs --tail 200 remote-deploy-server
```

- **Copiar arquivo diretamente para o container (sem SSH)**:
```bash
docker cp ./batch_output.txt remote-deploy-server:/home/devuser
docker exec -it remote-deploy-server chown devuser:devuser /home/devuser/batch_output.txt
```

- **Construir o JAR com Maven (dentro do diretório `demobatch`)**:
```bash
./demobatch/mvnw -f demobatch/pom.xml clean package -DskipTests
```

**Dicas e observações**
- **Variáveis de ambiente de datasource:** o serviço `ssh_java_server` já define `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME` e `SPRING_DATASOURCE_PASSWORD` para apontar ao serviço `mysql` na mesma rede do Compose. Se rodar o JAR fora do container, confirme se essas variáveis estão configuradas ou ajuste `application.properties`.
- **Crontab no container:** por padrão o container inicializado aqui não executa `cron` automaticamente. Se quiser ativar cron para testes, adicione `ENABLE_CRON=true` nas `environment` do serviço ou inicie manualmente com `docker exec remote-deploy-server service cron start`.
- **Segurança:** `allowPublicKeyRetrieval=true` e `useSSL=false` são adequados para desenvolvimento, não para produção. Em produção, prefira configurar o usuário do MySQL com `mysql_native_password` ou usar SSL apropriado.

**Ajuda / Troubleshooting**
- Se o SSH reclamar que a identificação do host mudou, remova a entrada antiga com o comando `ssh-keygen` acima e reconecte.
- Se o serviço não consegue conectar ao MySQL, verifique `docker logs mysql_db` para confirmar que o banco está `ready for connections`.

---
Atualize este README com seus comandos pessoais conforme necessário.

