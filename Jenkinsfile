pipeline {
    agent any

    // Bypasses local webhook networking issues: Jenkins polls the repo
    // every 2 minutes and only actually builds if it finds new commits.
    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        APP_IMAGE = "local-cicd-app:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${APP_IMAGE} ./app'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve -input=false -var="app_image=${APP_IMAGE}"'
                }
            }
        }
    }

    post {
        success {
            echo "Deployed ${APP_IMAGE}. App available at http://localhost:5001"
        }
    }
}
