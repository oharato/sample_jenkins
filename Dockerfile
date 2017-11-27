FROM jenkins:latest
USER root
# dockerコンテナ内でdockerを実行できるように、
# dockerのインストールやjenkinsユーザをdockerグループに加えています
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce && \
    usermod -aG docker jenkins

EXPOSE 8080 50000

USER jenkins
# jenkinsの起動オプションはここで指定できます
ENV JAVA_OPTS="-Djava.io.tmpDir=/var/jenkins_home/tmp -Duser.timezone=Asia/Tokyo -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Tokyo"
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

