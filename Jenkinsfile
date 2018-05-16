node {
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awsAccessCreds']]) {

    // Get the Terraform tool.

    // Setup environment vars
    env.TF_IN_AUTOMATION = "true"
    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {

            // Mark the code build 'plan'....
            stage name: 'Plan', concurrency: 1

            // Output Terraform version
            sh "terraform --version"

            //Remove the terraform state file so we always start from a clean state
            if (fileExists(".terraform/terraform.tfstate")) {
                sh "rm -rf .terraform/terraform.tfstate"
            }
            if (fileExists("status")) {
                sh "rm status"
            }

            // Terraform init
            sh "terraform init -input=false -force-copy -get=true"
            // Pull terraform remote state
            sh "terraform get"
            // Generate terraform plan
            sh "set +e; terraform plan -out=plan.out -var 'access_key=$AWS_ACCESS_KEY_ID' -var \
                'secret_key=$AWS_SECRET_ACCESS_KEY' -detailed-exitcode; echo \$? > status"\

            // Check status code
            def exitCode = readFile('status').trim()
            def apply = false
            echo "Terraform Plan Exit Code: ${exitCode}"
            if (exitCode == "0") {
                currentBuild.result = 'SUCCESS'
            }
            if (exitCode == "1") {
                slackSend channel: '#ci', color: '#0080ff', message: "Plan Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                currentBuild.result = 'FAILURE'
            }
            if (exitCode == "2") {
                stash name: "plan", includes: "plan.out"
                slackSend channel: '#ci', color: 'good', message: "Plan Awaiting Approval: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                try {
                    input message: 'Apply Plan?', ok: 'Apply'
                    apply = true
                } catch (err) {
                    slackSend channel: '#ci', color: 'warning', message: "Plan Discarded: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                    apply = false
                    currentBuild.result = 'UNSTABLE'
                }
            }

            if (apply) {
                stage name: 'Apply', concurrency: 1
                unstash 'plan'
                if (fileExists("status.apply")) {
                    sh "rm status.apply"
                }
                sh 'set +e; terraform apply -input=false plan.out; echo \$? > status.apply'
                def applyExitCode = readFile('status.apply').trim()
                if (applyExitCode == "0") {
                    slackSend channel: '#ci', color: 'good', message: "Changes Applied ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                } else {
                    slackSend channel: '#ci', color: 'danger', message: "Apply Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                    currentBuild.result = 'FAILURE'
                }
            }
    }
  }
}
