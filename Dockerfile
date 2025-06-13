FROM tomcat:9.0-jdk17-temurin

# Set environment variables
ENV NEXUS_REPO_URL=http://54.81.232.206:8081/repository/maven-snapshots
ENV ARTIFACT_PATH=in/javahome/hiring-app/0.1-SNAPSHOT/hiring-app-0.1-SNAPSHOT.war

# Download WAR from Nexus using curl and place it in Tomcat's webapps directory
RUN apt-get update && apt-get install -y curl && \
    curl -o /usr/local/tomcat/webapps/hiring.war "$NEXUS_REPO_URL/$ARTIFACT_PATH"

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
