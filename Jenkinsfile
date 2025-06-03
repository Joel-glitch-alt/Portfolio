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



// //Option 2pipeline 

//  pipeline {
//     agent any

//     tools {
//         nodejs "NodeJS-20" 
//     }

//     environment {
//         PATH = "${tool('SonarScanner')}/bin:${env.PATH}"
//         DOCKER_IMAGE = 'addition1905/project-six:latest' 
//     }

//     stages {
//         stage('Checkout') {
//             steps {
//                 checkout scm
//             }
//         }

//             stage('Install Dependencies') {
//     steps {
//         sh '''
//             echo "Node version:"
//             node -v

//             echo "NPM version:"
//             npm -v

//             echo "Installing dependencies..."
//             npm install

//             echo "Making jest executable..."
//             chmod +x ./node_modules/.bin/jest
//         '''
//     }
// }


//         stage('Run Tests and Coverage') {
//             steps {
//                 sh 'npm test'
//             }
//         }



//             stage('SonarQube Analysis') {
//     steps {
//         withCredentials([string(credentialsId: 'mysonar-token', variable: 'SONAR_TOKEN')]) {
//             withSonarQubeEnv('Sonar-server') {
//                 sh '''
//                     export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
//                     export PATH=$JAVA_HOME/bin:$PATH
//                     export SONAR_SCANNER_OPTS="-Xmx2048m"

//                     sonar-scanner \
//                       -Dsonar.projectKey=project-six \
//                       -Dsonar.projectName="Project Six" \
//                       -Dsonar.sources=. \
//                       -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
//                       -Dsonar.sourceEncoding=UTF-8 \
//                       -Dsonar.login=$SONAR_TOKEN
//                 '''
//             }
//         }
//     }
// }





//         // stage('Quality Gate') {
//         //     steps {
//         //         timeout(time: 20, unit: 'MINUTES') {
//         //             waitForQualityGate abortPipeline: true
//         //         }
//         //     }
//         // }
//         //
//          stage('Docker Build & Push') {
//         steps {
//             script {
//                 def img = docker.build("${DOCKER_IMAGE}")
//                 docker.withRegistry('https://index.docker.io/v1/', 'addition1905') {
//                     img.push()
//                 }
//             }
//         }
//     }
//     }

//     post {
//         always {
//             echo 'Pipeline completed. See SonarQube dashboard for results.'
//         }
//         failure {
//             echo '❌ Pipeline failed. Check logs.'
//         }
//     }
// }

pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS-20'
    }
    
    environment {
        PATH = "${tool('SonarScanner')}/bin:${env.PATH}"
        DOCKER_IMAGE = 'addition1905/project-six:latest'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
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
                    echo "Node version:"
                    node -v
                    
                    echo "NPM version:"
                    npm -v
                    
                    echo "Installing dependencies..."
                    npm install
                    
                    echo "Making jest executable..."
                    chmod +x ./node_modules/.bin/jest
                '''
            }
        }
        
        stage('Run Tests and Coverage') {
            steps {
                sh 'npm test'
            }
            post {
                always {
                    // Archive test results if they exist (using junit step)
                    script {
                        if (fileExists('test-results.xml')) {
                            junit 'test-results.xml'
                        }
                        // Archive coverage reports if they exist
                        if (fileExists('coverage/index.html')) {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'coverage',
                                reportFiles: 'index.html',
                                reportName: 'Coverage Report'
                            ])
                        }
                    }
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'mysonar-token', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('Sonar-server') {
                        sh '''
                            # Ensure Java is available
                            if [ -d "$JAVA_HOME" ]; then
                                export PATH=$JAVA_HOME/bin:$PATH
                            fi
                            
                            export SONAR_SCANNER_OPTS="-Xmx2048m"
                            
                            # Check if coverage file exists
                            if [ -f "coverage/lcov.info" ]; then
                                COVERAGE_PARAM="-Dsonar.javascript.lcov.reportPaths=coverage/lcov.info"
                            else
                                echo "Warning: coverage/lcov.info not found, proceeding without coverage"
                                COVERAGE_PARAM=""
                            fi
                            
                            sonar-scanner \
                                -Dsonar.projectKey=project-six \
                                -Dsonar.projectName="Project Six" \
                                -Dsonar.sources=. \
                                -Dsonar.sourceEncoding=UTF-8 \
                                -Dsonar.login=$SONAR_TOKEN \
                                $COVERAGE_PARAM
                        '''
                    }
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
        
        stage('Docker Build & Push') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'develop'
                }
            }
            steps {
                script {
                    try {
                        def img = docker.build("${DOCKER_IMAGE}")
                        docker.withRegistry('https://index.docker.io/v1/', 'addition1905') {
                            img.push()
                            img.push('latest')
                        }
                        echo "✅ Docker image pushed successfully: ${DOCKER_IMAGE}"
                    } catch (Exception e) {
                        error "❌ Docker build/push failed: ${e.getMessage()}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed. See SonarQube dashboard for results.'
            // Clean up workspace
            cleanWs()
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
        unstable {
            echo '⚠️ Pipeline completed with warnings...'
        }
    }
}
    