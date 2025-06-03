// Working
// pipeline {
//     agent any

//     environment {
//         SONAR_AUTH_TOKEN = credentials('SonarQube-token')
//     }

//     stages {
//         stage('Say Hello') {
//             steps {
//                 echo 'Hello from Jenkins pipeline!'
//             }
//         }

//         stage('SonarQube Analysis') {
//             steps {
//                 withSonarQubeEnv('Sonar-server') {
//                     script {
//                         def scannerHome = tool name: 'SonarScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
//                         sh """
//                             ${scannerHome}/bin/sonar-scanner \
//                                 -Dsonar.projectKey=Project-five \
//                                 -Dsonar.sources=. \
//                                 -Dsonar.host.url=$SONAR_HOST_URL \
//                                 -Dsonar.login=$SONAR_AUTH_TOKEN
//                         """
//                     }
//                 }
//             }
//         }

//         stage('Quality Gate') {
//             steps {
//                 timeout(time: 5, unit: 'MINUTES') {
//                     waitForQualityGate abortPipeline: true
//                 }
//             }
//         }
//     }

//     post {
//         always {
//             cleanWs()
//         }
//         failure {
//             echo '❌ Build failed. Check the logs above.'
//         }
//         unstable {
//             echo '⚠️ Build unstable due to test failures.'
//         }
//         success {
//             echo '✅ Build completed successfully...'
//         }
//     }
// }



//Option 2
pipeline {
    agent {
        docker {
            image 'node:18-alpine'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        SONAR_AUTH_TOKEN = credentials('SonarQube-token')
    }

    stages {
        stage('Say Hello') {
            steps {
                echo 'Hello from Jenkins pipeline!'
                sh 'node --version'
                sh 'npm --version'
            }
        }

        stage('Build & Test with Coverage') {
            steps {
                script {
                    sh 'npm install'
                    // Fix permission issue
                    sh 'chmod +x ./node_modules/.bin/jest'
                    // Run tests with coverage
                    sh 'npm test -- --coverage'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar-server') {
                    script {
                        sh '''
                            # Install required utilities
                            apk add --no-cache unzip wget

                            # Download and unzip SonarScanner
                            wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
                            unzip -q sonar-scanner-cli-4.8.0.2856-linux.zip
                            export PATH=$PATH:$(pwd)/sonar-scanner-4.8.0.2856-linux/bin

                            # Run SonarScanner
                            ./sonar-scanner-4.8.0.2856-linux/bin/sonar-scanner \
                                -Dsonar.projectKey=Project-five \
                                -Dsonar.sources=. \
                                -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_AUTH_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
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
            echo '✅ Build completed successfully...'
        }
    }
}
