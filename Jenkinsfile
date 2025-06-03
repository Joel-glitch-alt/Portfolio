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
                    // Use SonarQube Scanner tool configured in Jenkins
                    tool name: 'Sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    sh '''
                      ${tool('Sonar-scanner')}/bin/sonar-scanner \
                        -Dsonar.projectKey=Project-five \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }
    }
}
