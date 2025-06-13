pipeline {
    agent any

    environment {
        SONAR_HOST = 'http://54.81.232.206:9000'
        SONAR_TOKEN_CREDENTIAL_ID = 'sonar'

        NEXUS_URL = 'http://54.81.232.206:8081/repository/maven-snapshots/'
        NEXUS_USERNAME = 'admin'
        NEXUS_PASSWORD = 'Mubsad321.'

        SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/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'

        TOMCAT_URL = 'http://54.81.232.206:8083/manager/text'
        TOMCAT_USERNAME = 'admin'
        TOMCAT_PASSWORD = 'admin123'
        APP_CONTEXT = 'hiring-app'

        GIT_REPO = 'https://github.com/mubeen-hub78/hiring-app.git'
        GIT_BRANCH = 'main'

        DOCKER_IMAGE_NAME = 'sabair0509/hiring-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Git Clone Application Code') {
            steps {
                echo 'Cloning application repository...'
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}"
            }
        }

        stage('Build with Maven') {
            steps {
                echo 'Building with Maven inside Docker...'
                script {
                    def containerProjectRoot = "/app"
                    sh """
                        docker run --rm \\
                          -v "${env.WORKSPACE}:${containerProjectRoot}" \\
                          -v /var/lib/jenkins/.m2:/root/.m2 \\
                          -w "${containerProjectRoot}" \\
                          maven:3.8.6-eclipse-temurin-17 \\
                          mvn clean compile package -DskipTests
                    """

                    sh """
                        if [ ! -d "${env.WORKSPACE}/target" ]; then
                          echo "ERROR: target directory not found. Build probably failed."
                          exit 1
                        fi
                    """
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube analysis...'
                script {
                    withCredentials([string(credentialsId: "${env.SONAR_TOKEN_CREDENTIAL_ID}", variable: 'SONAR_TOKEN')]) {
                        def containerProjectRoot = "/app"
                        sh """
                            docker run --rm \\
                              -e SONAR_HOST_URL=${SONAR_HOST} \\
                              -e SONAR_TOKEN=${SONAR_TOKEN} \\
                              -v "${env.WORKSPACE}:${containerProjectRoot}" \\
                              -w "${containerProjectRoot}" \\
                              sonarsource/sonar-scanner-cli \\
                              -Dsonar.projectKey=${APP_CONTEXT} \\
                              -Dsonar.sources=src \\
                              -Dsonar.java.binaries=target/classes \\
                              -Dsonar.host.url=${SONAR_HOST} \\
                              -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                echo 'Deploying artifact to Nexus via Maven...'
                script {
                    def containerProjectRoot = "/app"
                    sh """
                        docker run --rm \\
                          -v "${env.WORKSPACE}:${containerProjectRoot}" \\
                          -v /var/lib/jenkins/.m2:/root/.m2 \\
                          -w "${containerProjectRoot}" \\
                          maven:3.8.6-eclipse-temurin-17 \\
                          mvn deploy -s /root/.m2/settings.xml
                    """
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build . -t ${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub', variable: 'hubPwd')]) {
                    sh "docker login -u sabair0509 -p ${hubPwd}"
                    sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo 'Deploying WAR to Tomcat...'
                script {
                    def warFile = findFiles(glob: "target/${APP_CONTEXT}.war")[0]?.path
                    if (!warFile) {
                        error "WAR file not found for deployment."
                    }

                    sh """
                        curl -T ${warFile} \\
                          "${TOMCAT_URL}/deploy?path=/${APP_CONTEXT}&update=true" \\
                          --user ${TOMCAT_USERNAME}:${TOMCAT_PASSWORD}
                    """
                }
            }
        }

        stage('Slack Notification') {
            steps {
                echo 'Sending Slack notification...'
                script {
                    def message = """
                        {
                            "text": "✅ *Build and Deployment SUCCESSFUL* for *${APP_CONTEXT}* (Build #${BUILD_NUMBER}) on *${GIT_BRANCH}* branch! 🚀"
                        }
                    """
                    sh """
                        curl -X POST -H 'Content-type: application/json' \\
                          --data '${message}' ${SLACK_WEBHOOK_URL}
                    """
                }
            }
        }
    }
}
