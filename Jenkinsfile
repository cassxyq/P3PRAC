pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World 1'
            }
        }

        stage('test branch') {
            when {
                branch 'test1'
            }
            steps {
                echo 'Hello test1'
            }
        }

        stage('main branch') {
            when{
                branch 'main'
            }
            steps {
                echo 'MAIN BRANCH'
            }
        }
    }
    
    post {
        always{
            cleanWs()
        }

        /*success{
            emailext body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to: '$DEFAULT_RECIPIENTS'
        }

        failure{
            emailext body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to: '$DEFAULT_RECIPIENTS'
        }*/
    
    }
}

/*pipeline {
    agent any
    /*parameters {
        booleanParam defaultValue: false, name: 'TFapply'
        booleanParam defaultValue: false, name: 'Dependencies'
        booleanParam defaultValue: false, name: 'Upload'
        booleanParam defaultValue: false, name: 'TFdestroy'
    }

    options {
        ansiColor('xterm')
    }

    environment {
        AWS_CRED = 'casstest'
        S3_BUCKET = 'test.notfound404.click'
        TF_DIR = "frontend/frontend"
        WORKDIR = "./client"
    }

    stages {
        /*stage('SCM') {
            steps {
                //git url: "https://github.com/kodi24fever/reactjs-portfolio.git" ,branch: "master"
                //git url: "https://github.com/Crazyorchid/cont8-test.git" ,branch: "main"
                git url: "https://github.com/teambit/react-demo-app.git" ,branch: "master"
            }
        } 
        stage("intall & build"){
            when {expression{return params.Dependencies}}
            steps{
                dir(WORKDIR){
                    sh "npm install && npm run build"
                }
            }
        }

        /*stage("tfapply"){
            //when {expression{return params.TFapply}}
            steps{
                withAWS(credentials: 'casstest', region: 'ap-southeast-2'){
                    dir(TF_DIR){
                        sh "./run.sh"
                    }
                } 
            }
        }

        /*stage("upload"){
            when {expression{return params.Upload}}
            steps{
                withAWS(credentials: AWS_CRED, region: 'ap-southeast-2'){
                    script{
                    //sh "aws s3 sync ${env.WORKSPACE}/client/dist s3://${S3_BUCKET}/ "
                      sh "aws s3 sync ./client/build s3://${S3_BUCKET}/"
                    }
                }
            }
        }

        stage("destroy"){
            //when {when {expression{return params.TFdestroy}}}
            steps{
                withAWS(credentials: 'casstest', region: 'ap-southeast-2'){
                    dir(TF_DIR){
                        sh "./destroy.sh"
                    }
                } 
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
}*/
