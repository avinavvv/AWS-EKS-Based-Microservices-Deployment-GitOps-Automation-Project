@Library('Shared') _

pipeline {
    agent { label 'Node' }

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timeout(time: 90, unit: 'MINUTES')
    }

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        SONAR_SERVER = 'Sonar'
        SONAR_SCANNER = 'Sonar'
        SONAR_PROJECT_KEY = 'online-boutique'
        OWASP_TOOL = 'OWASP'
    }

    stages {
        stage('Workspace Cleanup') {
            steps {
                cleanWs()
            }
        }

        stage('Git: Code Checkout') {
            steps {
                codeCheckout(
                    'https://github.com/avinavvv/Production-Grade_GitOps-Driven_Microservices-Demo.git',
                    'main'
                )
            }
        }

        stage('Discover Microservices') {
            steps {
                script {
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                    env.SERVICES = discoverServices()

                    if (!env.SERVICES?.trim()) {
                        error('No services found under src/*/Dockerfile')
                    }

                    echo "Image tag: ${env.IMAGE_TAG}"
                    echo "Services to build:\n${env.SERVICES}"
                }
            }
        }

        stage('Trivy: Filesystem Scan') {
            steps {
                trivyFilesystem()
            }
        }

        stage('OWASP: Dependency Check') {
            steps {
                dependencyCheck()
            }
        }

        stage('SonarQube: Code Analysis') {
            steps {
                sonarAnalysis(
                    env.SONAR_PROJECT_KEY,
                    'Online Boutique',
                    'src'
                )
            }
        }

        stage('SonarQube: Quality Gate') {
            steps {
                sonarQualityGate()
            }
        }

        stage('Docker: Build All Microservices') {
            steps {
                dockerBuildAll()
            }
        }

        stage('Trivy: Image Scan') {
            steps {
                trivyImageScan()
            }
        }

        stage('Docker: Push to Docker Hub') {
            steps {
                dockerPushAll()
            }
        }
    }

    post {
        always {
            sh 'docker logout >/dev/null 2>&1 || true'
            echo 'CI pipeline completed. Review stage logs and reports.'
        }

        success {
            echo 'All microservice images passed the configured checks and were pushed.'
        }

        failure {
            echo 'CI failed. Fix the failed stage before retrying.'
        }
    }
}
