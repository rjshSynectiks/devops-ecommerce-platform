pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify') {
            steps {
                echo 'Jenkins successfully checked out the devops-ecommerce-platform repository.'
                sh 'java -version'

                dir('services/product-service') {
                    sh './mvnw -version'
                }
            }
        }

        stage('Build and Test') {
            steps {
                dir('services/product-service') {
                    sh './mvnw test'
                }
            }
        }
    }
}