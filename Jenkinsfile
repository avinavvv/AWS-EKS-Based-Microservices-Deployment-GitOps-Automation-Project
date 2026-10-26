@Library('Shared') _

pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timeout(time: 90, unit: 'MINUTES')
    }

    environment {
        REPOSITORY_URL = 'https://github.com/avinavvv/Production-Grade_GitOps-Driven_Microservices-Demo.git'
        GIT_BRANCH = 'main'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        SONAR_INSTALLATION = 'Sonar'
        SONAR_PROJECT_KEY = 'online-boutique'
        SONAR_PROJECT_NAME = 'Online Boutique'
        SONAR_SOURCES = 'src'
        OWASP_TOOL = 'OWASP'
        IMAGE_TAG_LENGTH = '12'
        TRIVY_SEVERITIES = 'HIGH,CRITICAL'
        TRIVY_EXIT_CODE = '0'
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
                    env.REPOSITORY_URL,
                    env.GIT_BRANCH
                )
            }
        }

        stage('Discover Microservices') {
            steps {
                discoverServices(env.IMAGE_TAG_LENGTH)
            }
        }

        stage('Trivy: Filesystem Scan') {
            steps {
                trivyFilesystem(
                    env.TRIVY_SEVERITIES,
                    env.TRIVY_EXIT_CODE
                )
            }
        }

        stage('OWASP: Dependency Check') {
            steps {
                dependencyCheck(env.OWASP_TOOL)
            }
        }

        stage('SonarQube: Code Analysis') {
            steps {
                sonarAnalysis(
                    env.SONAR_INSTALLATION,
                    env.SONAR_PROJECT_KEY,
                    env.SONAR_PROJECT_NAME,
                    env.SONAR_SOURCES
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
                dockerBuildAll(env.DOCKERHUB_CREDENTIALS)
            }
        }

        stage('Trivy: Image Scan') {
            steps {
                trivyImageScan(
                    env.DOCKERHUB_CREDENTIALS,
                    env.TRIVY_SEVERITIES,
                    env.TRIVY_EXIT_CODE
                )
            }
        }

        stage('Docker: Push to Docker Hub') {
            steps {
                dockerPushAll(env.DOCKERHUB_CREDENTIALS)
            }
        }
    }

    post {
        always {
            sh 'docker logout >/dev/null 2>&1 || true'
            echo 'CI pipeline completed. Review stage logs and reports.'
        }

        success {
            echo 'All stages passed and images were pushed.'
        }

        failure {
            echo 'Pipeline failed. Check the failed stage logs.'
        }
    }
}
