pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/TechnoBureau/demo.git'
        COMMON_DIR = "${env.JENKINS_HOME}/repo"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def commonDirContainsRepo = fileExists("${COMMON_DIR}/.git")

                    if (!commonDirContainsRepo) {
                        echo "Cloning repository"
                        sh "git clone ${GIT_REPO_URL} ${COMMON_DIR}"
                    } else {
                        echo "Pulling updates"
                        sh """
                        git -C ${COMMON_DIR} config pull.rebase false
                        git -C ${COMMON_DIR} pull origin main
                        """
                    }

                    sh "ln -s ${COMMON_DIR} ${WORKSPACE}/repo"
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    dir("${COMMON_DIR}") {
                        echo "Building"
                        // Your build steps go here
                    }
                }
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}
