pipeline {
    agent any

    stages {
        stage('Say Hello') {
            steps {
                echo 'Hello from Jenkins pipeline!'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar-server') {
                    script {
                        def scannerHome = tool name: 'SonarScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                              -Dsonar.projectKey=Project-five \
                              -Dsonar.sources=. \
                              -Dsonar.host.url=$SONAR_HOST_URL \
                              -Dsonar.login=$SONAR_AUTH_TOKEN
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        failure {
            echo '❌ Build failed. Check the logs above.'
        }
        unstable {
            echo '⚠️ Build unstable due to test failures.'
        }
        success {
            echo '✅ Build completed successfully.'
        }
    }
}
