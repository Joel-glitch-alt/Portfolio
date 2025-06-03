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



// //Option 2pipeline {
 pipeline {
    agent any

    tools {
        nodejs "NodeJS_18" // Match your Jenkins NodeJS tool installation name
        // Assuming sonar-scanner tool configured as "sonar-scanner"
    }

    environment {
        PATH = "${tool('sonar-scanner')}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                  npm install
                  chmod +x ./node_modules/.bin/jest
                '''
            }
        }

        stage('Run Tests and Coverage') {
            steps {
                sh 'npm test'
            }
        }

          stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('Sonar-server') {
            sh '''
                export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
                export PATH=$JAVA_HOME/bin:$PATH
                java -version  # For verification in logs
                sonar-scanner \
                  -Dsonar.projectKey=project-five \
                  -Dsonar.projectName="Project-five" \
                  -Dsonar.sources=. \
                  -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                  -Dsonar.sourceEncoding=UTF-8
            '''
        }
    }
}


        stage('Quality Gate') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed. See SonarQube dashboard for results.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs.'
        }
    }
}



