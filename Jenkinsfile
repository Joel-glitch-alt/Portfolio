// // Option 3: Complete Jenkins Pipeline for Node.js Project with SonarQube and Docker
// pipeline {
//     agent any
    
//     tools {
//         nodejs 'NodeJS-20'
//     }
    
//     environment {
//         PATH = "${tool('SonarScanner')}/bin:${env.PATH}"
//         DOCKER_IMAGE = 'addition1905/project-six:latest'
//         JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
//     }
    
//     stages {
//         stage('Checkout') {
//             steps {
//                 checkout scm
//             }
//         }
        
//         stage('Install Dependencies') {
//             steps {
//                 sh '''
//                     echo "Node version:"
//                     node -v
                    
//                     echo "NPM version:"
//                     npm -v
                    
//                     echo "Installing dependencies..."
//                     npm install
                    
//                     echo "Making jest executable..."
//                     chmod +x ./node_modules/.bin/jest
//                 '''
//             }
//         }
        
//         stage('Run Tests and Coverage') {
//             steps {
//                 sh 'npm test'
//             }
//             post {
//                 always {
//                     // Archive test results if they exist (using junit step)
//                     script {
//                         if (fileExists('test-results.xml')) {
//                             junit 'test-results.xml'
//                         }
//                         // Archive coverage reports if they exist
//                         if (fileExists('coverage/index.html')) {
//                             publishHTML([
//                                 allowMissing: false,
//                                 alwaysLinkToLastBuild: true,
//                                 keepAll: true,
//                                 reportDir: 'coverage',
//                                 reportFiles: 'index.html',
//                                 reportName: 'Coverage Report'
//                             ])
//                         }
//                     }
//                 }
//             }
//         }
        
//         stage('SonarQube Analysis') {
//             steps {
//                 withCredentials([string(credentialsId: 'mysonar-token', variable: 'SONAR_TOKEN')]) {
//                     withSonarQubeEnv('Sonar-server') {
//                         sh '''
//                             # Ensure Java is available
//                             if [ -d "$JAVA_HOME" ]; then
//                                 export PATH=$JAVA_HOME/bin:$PATH
//                             fi
                            
//                             export SONAR_SCANNER_OPTS="-Xmx2048m"
                            
//                             # Check if coverage file exists
//                             if [ -f "coverage/lcov.info" ]; then
//                                 COVERAGE_PARAM="-Dsonar.javascript.lcov.reportPaths=coverage/lcov.info"
//                             else
//                                 echo "Warning: coverage/lcov.info not found, proceeding without coverage"
//                                 COVERAGE_PARAM=""
//                             fi
                            
//                             sonar-scanner \
//                                 -Dsonar.projectKey=project-six \
//                                 -Dsonar.projectName="Project Six" \
//                                 -Dsonar.sources=. \
//                                 -Dsonar.sourceEncoding=UTF-8 \
//                                 -Dsonar.login=$SONAR_TOKEN \
//                                 $COVERAGE_PARAM
//                         '''
//                     }
//                 }
//             }
//         }
        
//         // stage('Quality Gate') {
//         //     steps {
//         //         timeout(time: 20, unit: 'MINUTES') {
//         //             waitForQualityGate abortPipeline: true
//         //         }
//         //     }
//         // }
        
//         stage('Docker Build & Push') {
//             when {
//                 anyOf {
//                     branch 'main'
//                     branch 'master'
//                     branch 'develop'
//                 }
//             }
//             steps {
//                 script {
//                     try {
//                         def img = docker.build("${DOCKER_IMAGE}")
//                         docker.withRegistry('https://index.docker.io/v1/', 'addition1905') {
//                             img.push()
//                             img.push('latest')
//                         }
//                         echo "✅ Docker image pushed successfully: ${DOCKER_IMAGE}"
//                     } catch (Exception e) {
//                         error "❌ Docker build/push failed: ${e.getMessage()}"
//                     }
//                 }
//             }
//         }
//     }
    
//     post {
//         always {
//             echo 'Pipeline completed. See SonarQube dashboard for results.'
//             // Clean up workspace
//             cleanWs()
//         }
//         success {
//             echo '✅ Pipeline completed successfully!'
//         }
//         failure {
//             echo '❌ Pipeline failed. Check logs for details.'
//         }
//         unstable {
//             echo '⚠️ Pipeline completed with warnings...'
//         }
//     }
// }

//Option 4
 pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS-20'
    }
    
    environment {
        PATH = "${tool('SonarScanner')}/bin:${env.PATH}"
        DOCKER_IMAGE = 'addition1905/project-six:latest'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        SONAR_SCANNER_OPTS = "-Xmx4096m"
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
                    script {
                        if (fileExists('test-results.xml')) {
                            junit 'test-results.xml'
                        }
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
                                -Dsonar.exclusions="**/node_modules/**,**/coverage/**,**/dist/**,**/build/**,**/*.min.js,**/public/**,.git/**,**/.git/**" \
                                -Dsonar.test.inclusions="**/*.test.js,**/*.spec.js" \
                                -Dsonar.coverage.exclusions="**/node_modules/**,**/coverage/**,**/dist/**,**/*.test.js,**/*.spec.js" \
                                -Dsonar.sourceEncoding=UTF-8 \
                                -Dsonar.token=$SONAR_TOKEN \
                                $COVERAGE_PARAM
                        '''
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        try {
                            echo "Waiting for Quality Gate result..."
                            def qg = waitForQualityGate abortPipeline: false
                            echo "Quality Gate status: ${qg.status}"
                            
                            if (qg.status != 'OK') {
                                echo "⚠️ Quality Gate failed with status: ${qg.status}"
                                echo "Check SonarQube dashboard for details"
                                currentBuild.result = 'UNSTABLE'
                            } else {
                                echo "✅ Quality Gate passed successfully!"
                            }
                        } catch (Exception e) {
                            echo "⚠️ Quality Gate timeout or error: ${e.getMessage()}"
                            echo "Pipeline will continue - check SonarQube manually"
                            currentBuild.result = 'UNSTABLE'
                        }
                    }
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