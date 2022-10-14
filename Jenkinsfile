pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World 1'
            }
        }
    }

    post {
        always{
            cleanWs()
        }

        success{
            emailext body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to: '$DEFAULT_RECIPIENTS'
        }

        failure{
            emailext body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to: '$DEFAULT_RECIPIENTS'
        }
    
    }
}

