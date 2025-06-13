FROM tomcat:9.0-jdk17-temurin

ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD
ENV NEXUS_REPO_URL=http://54.81.232.206:8081/repository/maven-releases
ENV ARTIFACT_PATH=in/javahome/hiring-app/0.1/hiring-app-0.1.war

RUN apt-get update && apt-get install -y curl && \
    curl -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" -o /usr/local/tomcat/webapps/hiring-app.war "$NEXUS_REPO_URL/$ARTIFACT_PATH"

EXPOSE 8080

CMD ["catalina.sh", "run"]
