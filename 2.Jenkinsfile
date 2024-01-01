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
      string(name: 'IMAGES', description: 'Specify the images')
    }

    environment {
        GIT_REPO_URL = 'https://github.com/TechnoBureau/demo.git'
        COMMON_DIR = "${env.JENKINS_HOME}/repo"
        VERSION_DIR = "${COMMON_DIR}/repo_${params.RELEASE_VERSION}"
        LINK_DIR = "${WORKSPACE}/repo"
        GITHUB_REF = "ref/head/main"
        GITHUB_TOKEN = credentials('GITHUB_TOKEN')
        VERSION = "1.0.0"
        IMAGES = "*"
        IMAGES_METADATA = null

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
                    def scriptOutput = sh(script: '''
                        ./scripts/initialize.sh "'${GITHUB_REF}'" "'${GITHUB_TOKEN}'" "'${VERSION}'" "'${IMAGES}'"
                    ''', returnStdout: true).trim()


                    // Parse key-value pairs from the script output
                    def imagesKeyValue = scriptOutput =~ /images=(.*)/
                    def images_metadataKeyValue = scriptOutput =~ /images_metadata=(.*)/

                    // Extract values from the matches
                    IMAGES = imagesKeyValue ? imagesKeyValue[0][1].trim() : null
                    IMAGES_METADATA = images_metadataKeyValue ? images_metadataKeyValue[0][1].trim() : null

                    // Now you can use 'images' and 'images_metadata' in your pipeline
                    echo "Parsed Images: ${IMAGES}"
                    echo "Parsed Images Metadata: ${IMAGES_METADATA}"
                    }
                }
            }
        }
        stage('Use Images in Another Stage') {
            steps {
                script {
                    // Now you can use 'IMAGES' and 'IMAGES_METADATA' in subsequent stages or steps
                    echo "Using Images in Another Stage: ${IMAGES}"
                    echo "Using Images Metadata in Another Stage: ${IMAGES_METADATA}"
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
