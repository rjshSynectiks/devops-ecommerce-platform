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
            }
        }
    }
}