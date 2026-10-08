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

        stage('Docker Build and Push') {
            steps {
                dir('services/product-service') {
                    script {
                        docker.withRegistry(
                            'https://index.docker.io/v1/',
                            'dockerhub-credentials'
                        ) {
                            def image = docker.build(
                                "rjshsynectiks/ecommerce-product-service:${BUILD_NUMBER}"
                            )

                            image.push()
                        }
                    }
                }
            }
        }
        stage('Test Kubernetes Access') {
    steps {
        withCredentials([
            file(
                credentialsId: 'docker-desktop-ecommerce-kubeconfig',
                variable: 'KUBECONFIG'
            )
        ]) {
            sh '''
                echo "Testing Kubernetes access..."
                kubectl --kubeconfig "$KUBECONFIG" --tls-server-name desktop-control-plane get deployment product-service -n ecommerce
            '''
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