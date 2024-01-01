def checkoutRepository(branch, dir) {
    // Check if the repository directory already contains the repository
    def containsRepo = fileExists("${dir}/.git")

    if (!containsRepo) {
        sh "git clone ${GIT_REPO_URL} ${dir}"
    } else {
        sh """
            git -C ${dir} config pull.rebase false
            git -C ${dir} pull origin ${branch}
        """
    }

    // Create a symlink to the directory inside the workspace
    sh "ln -s ${dir} ${LINK_DIR}"
}

pipeline {
    agent any

    parameters {
        string(name: 'RELEASE_VERSION', description: 'Enter the release version (e.g., 1.0.0)', defaultValue: '1.0.0')
    }

    environment {
        GIT_REPO_URL = 'https://github.com/TechnoBureau/demo.git'
        COMMON_DIR = "${env.JENKINS_HOME}/repo"
        VERSION_DIR = "${COMMON_DIR}/repo_${params.RELEASE_VERSION}"
        LINK_DIR = "${WORKSPACE}/repo"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def releaseBranch = "release/${params.RELEASE_VERSION}"

                    // Check if the release branch exists
                    def branchExists = sh(script: "git ls-remote --exit-code --heads ${GIT_REPO_URL} ${releaseBranch}", returnStatus: true) == 0

                    if (branchExists) {
                        dir(VERSION_DIR) {
                            checkoutRepository("release/${params.RELEASE_VERSION}", VERSION_DIR)
                        }
                    } else {
                        dir(COMMON_DIR) {
                            checkoutRepository("main", COMMON_DIR)
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    dir("${LINK_DIR}") {
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
