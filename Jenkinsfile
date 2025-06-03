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
        // Cache directory for faster builds
        NPM_CONFIG_CACHE = '/tmp/.npm'
    }

    options {
        // Keep builds for 30 days, max 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
        // Timeout after 20 minutes
        timeout(time: 20, unit: 'MINUTES')
        // Skip checkout to default agent
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout & Setup') {
            steps {
                // Manual checkout for better control
                checkout scm
                
                echo 'Setting up build environment...'
                sh '''
                    echo "Node version: $(node --version)"
                    echo "NPM version: $(npm --version)"
                    
                    # Install system dependencies once
                    apk add --no-cache unzip wget bash curl
                    
                    # Setup SonarQube scanner (cached approach)
                    if [ ! -f "/tmp/sonar-scanner/bin/sonar-scanner" ]; then
                        echo "Installing SonarQube scanner..."
                        wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip -O /tmp/sonar-scanner.zip
                        unzip -q /tmp/sonar-scanner.zip -d /tmp/
                        mv /tmp/sonar-scanner-5.0.1.3006-linux /tmp/sonar-scanner
                        rm /tmp/sonar-scanner.zip
                    else
                        echo "SonarQube scanner already installed"
                    fi
                    
                    # Add to PATH
                    export PATH=$PATH:/tmp/sonar-scanner/bin
                    echo "SonarQube scanner version: $(sonar-scanner --version || echo 'Not found')"
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing NPM dependencies...'
                sh '''
                    # Use npm ci for faster, reliable builds
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
                        // Only run if lint script exists
                        expression { 
                            return sh(script: 'npm run lint --silent 2>/dev/null', returnStatus: true) == 0 
                        }
                    }
                    steps {
                        echo 'Running linting...'
                        sh 'npm run lint'
                    }
                }
                
                  //
                  stage('Test with Coverage') {
            steps {
                echo 'Running tests with coverage...'
                sh '''
                    # Fix permissions if needed
                    chmod +x ./node_modules/.bin/* 2>/dev/null || true
                    
                    # Run tests with coverage
                    npm test -- --coverage --watchAll=false --passWithNoTests
                    
                    # Display coverage summary in console
                    if [ -f coverage/lcov.info ]; then
                        echo "✅ Coverage report generated successfully"
                        echo "📊 Coverage files created:"
                        ls -la coverage/
                    else
                        echo "⚠️ No coverage report found"
                    fi
                '''
            }
            
            post {
                always {
                    // Archive coverage files
                    script {
                        if (fileExists('coverage')) {
                            archiveArtifacts artifacts: 'coverage/**/*', allowEmptyArchive: true
                            echo "📊 Coverage reports archived - check build artifacts"
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
                    script {
                        echo 'Running SonarQube analysis...'
                        sh '''
                            export PATH=$PATH:/tmp/sonar-scanner/bin
                            
                            # Create sonar-project.properties if it doesn't exist
                            if [ ! -f sonar-project.properties ]; then
                                cat > sonar-project.properties << EOF
sonar.projectKey=Project-five
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
                            
                            # Run SonarScanner
                            sonar-scanner \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_AUTH_TOKEN \
                                -Dsonar.projectKey=Project-five \
                                -Dsonar.sources=. \
                                -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                        '''
                    }
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
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                        echo "✅ Quality Gate passed with status: ${qg.status}"
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
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed. Cleaning up...'
            
            // Archive artifacts
            archiveArtifacts artifacts: 'coverage/**/*', allowEmptyArchive: true
            
            // Publish test results if they exist
            script {
                if (fileExists('coverage/clover.xml')) {
                    publishTestResults testResultsPattern: 'coverage/clover.xml'
                }
            }
            
            // Clean workspace
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
            echo '❌ Build failed. Check the logs above.'
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