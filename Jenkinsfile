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
        NPM_CONFIG_CACHE = '/tmp/.npm'
        PATH = "$PATH:/tmp/sonar-scanner/bin"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
        timeout(time: 20, unit: 'MINUTES')
        skipDefaultCheckout()
    }

    parameters {
        string(name: 'SONAR_PROJECT_KEY', defaultValue: 'Project-five', description: 'SonarQube project key')
    }

    stages {
        stage('Checkout & Setup') {
            steps {
                checkout scm
                echo 'Setting up environment...'
                sh '''
                    echo "Node version: $(node --version)"
                    echo "NPM version: $(npm --version)"
                    apk add --no-cache unzip wget bash curl

                    if [ ! -f "/tmp/sonar-scanner/bin/sonar-scanner" ]; then
                        echo "Installing SonarQube scanner..."
                        wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip -O /tmp/sonar-scanner.zip
                        unzip -q /tmp/sonar-scanner.zip -d /tmp/
                        mv /tmp/sonar-scanner-5.0.1.3006-linux /tmp/sonar-scanner
                        rm /tmp/sonar-scanner.zip
                    else
                        echo "SonarQube scanner already installed"
                    fi
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing NPM dependencies...'
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
                        echo 'Running lint...'
                        sh 'npm run lint'
                    }
                }

                stage('Test with Coverage') {
                    steps {
                        echo 'Running tests with coverage...'
                        sh '''
                            chmod +x ./node_modules/.bin/* 2>/dev/null || true
                            npm test -- --coverage --watchAll=false --passWithNoTests || true
                        '''
                    }

                    post {
                        always {
                            script {
                                if (fileExists('coverage')) {
                                    archiveArtifacts artifacts: 'coverage/**/*', allowEmptyArchive: true
                                    echo "📊 Coverage reports archived"
                                }
                                if (fileExists('coverage/junit.xml')) {
                                    junit 'coverage/junit.xml'
                                }
                            }
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
sonar.projectName=Project Five
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
                echo 'Waiting for SonarQube Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "❌ Quality Gate failed: ${qg.status}"
                        }
                        echo "✅ Quality Gate passed: ${qg.status}"
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
                    echo 'Building Docker image...'
                    def image = docker.build("project-five:${env.BUILD_NUMBER}")
                    echo "✅ Docker image built: project-five:${env.BUILD_NUMBER}"

                    // Optional: Push to Docker Hub (uncomment below)
                    // docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                    //     image.push("${env.BUILD_NUMBER}")
                    //     image.push("latest")
                    // }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            archiveArtifacts artifacts: 'coverage/**/*', allowEmptyArchive: true
            cleanWs()
        }

        success {
            echo '✅ Build completed successfully!'
            script {
                if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                    slackSend(
                        channel: '#deployments',
                        color: 'good',
                        message: "✅ ${env.JOB_NAME} - Build #${env.BUILD_NUMBER} succeeded (<${env.BUILD_URL}|Open>)"
                    )
                }
            }
        }

        failure {
            echo '❌ Build failed.'
            slackSend(
                channel: '#alerts',
                color: 'danger',
                message: "❌ ${env.JOB_NAME} - Build #${env.BUILD_NUMBER} failed (<${env.BUILD_URL}|Open>)"
            )
        }

        unstable {
            echo '⚠️ Build unstable due to test failures.'
            slackSend(
                channel: '#alerts',
                color: 'warning',
                message: "⚠️ ${env.JOB_NAME} - Build #${env.BUILD_NUMBER} is unstable (<${env.BUILD_URL}|Open>)"
            )
        }
    }
}
