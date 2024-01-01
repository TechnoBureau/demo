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
    string(name: 'IMAGES', description: 'Specify the images', defaultValue: '*')
  }

  environment {
      GIT_REPO_URL = 'https://github.com/TechnoBureau/demo.git'
      COMMON_DIR = "${env.JENKINS_HOME}/repo"
      VERSION_DIR = "${COMMON_DIR}/repo_${params.RELEASE_VERSION}"
      LINK_DIR = "${WORKSPACE}/repo"
      GITHUB_REF = "ref/head/main"
      GITHUB_TOKEN = credentials('GITHUB_TOKEN')
      VERSION = "1.0.0"
      IMAGES = "${params.IMAGES}"
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
          }
          else {
            dir(COMMON_DIR) {
              checkoutRepository("main", COMMON_DIR)
            }
          }
        }
      }
    }

    stage('Initialize') {
      steps {
        script {
          dir("${LINK_DIR}") {
            // Run the initialization script and capture the output
            def scriptOutput = sh(script: '''
                ./scripts/initialize.sh "${GITHUB_REF}" "${GITHUB_TOKEN}" "${VERSION}" "${IMAGES}"
            ''', returnStdout: true).trim()

            // Parse key-value pairs from the script output
            def images_metadataKeyValue = scriptOutput =~ /images_metadata=(.*)/

            // Extract values from the matches
            IMAGES_METADATA = images_metadataKeyValue ? images_metadataKeyValue[0][1].trim() : null

            // Now you can use 'images' and 'images_metadata' in your pipeline
            echo "Parsed Images Metadata: ${IMAGES_METADATA}"
          }
        }
      }
    }
    stage('Build') {
      steps {
        script {
          // Use a script block to dynamically generate the matrix values
          def imagesMetadata = new groovy.json.JsonSlurper().parseText("${IMAGES_METADATA}")
          // Iterate through each image in the metadata
          imagesMetadata.each { imageName, imageDetails ->
              // Execute steps for each image
              echo "Building Image: ${imageName}"
              echo "Version: ${imageDetails.version}"
              echo "Platform: ${imageDetails.platform}"

              // Add your build steps here based on the image metadata
              // For example, you might want to build the image using Docker
              // docker.build("your-registry/${imageName}:${imageDetails.version}")
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
