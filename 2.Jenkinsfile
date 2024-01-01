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
                    // Run the initialization script and capture the output
                    def scriptOutput = sh(script: "./scripts/initialize.sh 'ref/head/main' '' '1.0.0' '*'", returnStdout: true).trim()

                    // Parse key-value pairs from the script output
                    def imagesKeyValue = scriptOutput =~ /images=\[(.*?)\]/
                    def images_metadataKeyValue = scriptOutput =~ /images_metadata=\{(.*?)\}/

                    // Extract values from the matches
                    def images = imagesKeyValue ? imagesKeyValue[0][1] : null
                    def images_metadata = images_metadataKeyValue ? images_metadataKeyValue[0][1] : null

                    // Now you can use 'images' and 'images_metadata' in your pipeline
                    echo "Parsed Images: ${images}"
                    echo "Parsed Images Metadata: ${images_metadata}"
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
