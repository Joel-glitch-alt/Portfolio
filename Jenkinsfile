//Jenkinsfile for Project 
pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS-20'
    }
    
    environment {
        PATH = "${tool('SonarScanner')}/bin:${env.PATH}"
        DOCKER_IMAGE = 'addition1905/project-six:latest'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        SONAR_SCANNER_OPTS = "-Xmx2048m -Dsonar.internal.analysis.dbd=false"
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
                script {
                    // Make SonarQube completely optional and non-blocking
                    try {
                        withCredentials([string(credentialsId: 'mysonar-token', variable: 'SONAR_TOKEN')]) {
                            withSonarQubeEnv('Sonar-server') {
                                timeout(time: 10, unit: 'MINUTES') {
                                    sh '''
                                        # Set Java path if available
                                        if [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
                                            export PATH=/usr/lib/jvm/java-17-openjdk-amd64/bin:$PATH
                                        fi

                                        # Ensure Node.js is available
                                        export NODE_PATH=$(which node)

                                        # Build sonar-scanner command with enhanced timeout and memory settings
                                        SONAR_CMD="sonar-scanner"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.projectKey=project-six"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.projectName=\\"Project Six\\""
                                        SONAR_CMD="$SONAR_CMD -Dsonar.sources=."
                                        SONAR_CMD="$SONAR_CMD -Dsonar.exclusions=**/node_modules/**,**/coverage/**,**/dist/**,**/build/**,**/*.min.js,**/public/**,.git/**,**/.git/**,**/*.test.js,**/*.spec.js"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.test.inclusions=**/*.test.js,**/*.spec.js"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.coverage.exclusions=**/node_modules/**,**/coverage/**,**/dist/**,**/*.test.js,**/*.spec.js"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.sourceEncoding=UTF-8"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.token=${SONAR_TOKEN}"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.nodejs.executable=$(which node)"
                                        
                                        # Memory and timeout optimization parameters
                                        SONAR_CMD="$SONAR_CMD -Dsonar.javascript.maxFileSize=500"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.typescript.maxFileSize=500"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.javascript.node.maxspace=4096"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.scanner.httpTimeout=300"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.scanner.socketTimeout=300"
                                        
                                        # Disable problematic sensors that might cause timeouts
                                        SONAR_CMD="$SONAR_CMD -Dsonar.javascript.detectBugs=false"
                                        SONAR_CMD="$SONAR_CMD -Dsonar.typescript.detectBugs=false"

                                        # Add coverage parameter if file exists
                                        if [ -f "coverage/lcov.info" ]; then
                                            SONAR_CMD="$SONAR_CMD -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info"
                                        fi
                     
                                        # Execute the command
                                        echo "Running: $SONAR_CMD"
                                        eval $SONAR_CMD
                                    '''
                                }
                            }
                        }
                        echo "✅ SonarQube Analysis completed successfully"
                    } catch (Exception e) {
                        echo "⚠️ SonarQube Analysis failed: ${e.getMessage()}"
                        echo "Pipeline will continue despite SonarQube failure..."
                        // Don't set currentBuild.result here to avoid affecting Docker stage
                    }
                }
            }
        }
        
        stage('Docker Build & Push') {
            // Remove branch restriction temporarily for testing
            // when {
            //     anyOf {
            //         branch 'main'
            //         branch 'master'
            //         branch 'develop'
            //     }
            // }
            steps {
                script {
                    echo "🐳 Starting Docker Build & Push..."
                    echo "Current branch: ${env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'unknown'}"
                    echo "Docker image: ${DOCKER_IMAGE}"
                    
                    try {
                        def img = docker.build("${DOCKER_IMAGE}")
                        docker.withRegistry('https://index.docker.io/v1/', 'addition1905') {
                            img.push()
                            img.push('latest')
                        }
                        echo "✅ Docker image pushed successfully: ${DOCKER_IMAGE}"
                    } catch (Exception e) {
                        echo "❌ Docker build/push failed: ${e.getMessage()}"
                        error "Docker build/push failed: ${e.getMessage()}"
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
            echo '⚠️ Pipeline completed with warnings....'
        }
    }
}