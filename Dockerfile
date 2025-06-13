FROM tomcat:9.0-jdk17-temurin

# Define arguments for Nexus credentials and artifact path
ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD
ENV NEXUS_REPO_URL=http://54.81.232.206:8081/repository/maven-releases
ENV ARTIFACT_PATH=in/javahome/hiring-app/0.1/hiring-app-0.1.war

# Download WAR from Nexus using curl and place it in Tomcat's webapps directory
# Install curl, then download the artifact using provided credentials.
RUN apt-get update && apt-get install -y curl && \
    curl -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" -o /usr/local/tomcat/webapps/hiring-app.war "$NEXUS_REPO_URL/$ARTIFACT_PATH"

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
