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
                    sh 'SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/ecommerce ./mvnw test'
                }
            }
        }

        stage('Package') {
            steps {
                dir('services/product-service') {
                    sh './mvnw package -DskipTests'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('services/product-service') {
                    sh 'docker build -t rjshsynectiks/ecommerce-product-service:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'services/product-service/target/*.jar', fingerprint: true
            }
        }
    }
}