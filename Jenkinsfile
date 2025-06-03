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
            args '-v /var/run/docker.sock:/var/run/docker.sock --user root'
        }
    }

    environment {
        SONAR_AUTH_TOKEN = credentials('SonarQube-token')
        SONAR_PROJECT_KEY = 'Project-five'
        NPM_CONFIG_CACHE = '/tmp/.npm'
        PATH = "$PATH:/tmp/sonar-scanner/bin"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
        timeout(time: 20, unit: 'MINUTES')
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout & Setup') {
            steps {
                checkout scm
                sh '''
                    apk add --no-cache unzip wget bash curl

                    if [ ! -f "/tmp/sonar-scanner/bin/sonar-scanner" ]; then
                        wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip -O /tmp/sonar-scanner.zip
                        unzip -q /tmp/sonar-scanner.zip -d /tmp/
                        mv /tmp/sonar-scanner-5.0.1.3006-linux /tmp/sonar-scanner
                        rm /tmp/sonar-scanner.zip
                    fi
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    if [ -f package-lock.json ]; then
                        npm ci --cache $NPM_CONFIG_CACHE
                    else
                        npm install --cache $NPM_CONFIG_CACHE
                    fi
                '''
            }
        }

        stage('Build & Test') {
            parallel {
                stage('Lint') {
                    when {
                        expression {
                            return sh(script: "node -p 'require(\"./package.json\").scripts.lint !== undefined'", returnStatus: true) == 0
                        }
                    }
                    steps {
                        sh 'npm run lint'
                    }
                }

                stage('Test with Coverage') {
                    steps {
                        sh '''
                            chmod +x ./node_modules/.bin/* 2>/dev/null || true
                            npm test -- --coverage --watchAll=false --passWithNoTests || true
                        '''
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'coverage/**/*', allowEmptyArchive: true
                            junit 'coverage/junit.xml'
                        }
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar-server') {
                    sh '''
                        if [ ! -f sonar-project.properties ]; then
                            cat > sonar-project.properties << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.projectName=Project-five
sonar.projectVersion=1.0
sonar.sources=src,./
sonar.sourceEncoding=UTF-8
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.coverage.exclusions=**/*.test.js,**/*.spec.js,**/node_modules/**,**/coverage/**
sonar.cpd.exclusions=**/*.test.js,**/*.spec.js
sonar.exclusions=**/node_modules/**,**/coverage/**,**/*.config.js
EOF
                        fi

                        sonar-scanner \
                            -Dsonar.host.url=$SONAR_HOST_URL \
                            -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Quality Gate failed: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'develop'
                }
            }
            steps {
                script {
                    def image = docker.build("project-five:${env.BUILD_NUMBER}")
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'coverage/**/*', allowEmptyArchive: true
            cleanWs()
        }
        success {
            slackSend(channel: '#deployments', color: 'good', message: "Build #${env.BUILD_NUMBER} succeeded")
        }
        failure {
            slackSend(channel: '#alerts', color: 'danger', message: "Build #${env.BUILD_NUMBER} failed")
        }
    }
}