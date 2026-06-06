pipeline{
    agent any
    stages{
        stage("Clone Repository"){
            steps{
                echo "========cloning repository========"
                git branch: "main",
                    url:"https://github.com/sanjeevprasad-25/terraform-nginx-azure.git"
            }
            post{
                success{
                    echo "========Cloned successfully========"
                }
                failure{
                    echo "========Clone failed========"
                }
            }
        }
        stage("Initializing Terraform"){
            steps{
               dir('terraform'){
                    echo "========Initialize Terraform ========"
                    sh 'terraform init'
                }
            }
                
            post{
                success{
                    echo "========Initialize successfully========"
                }
                failure{
                    echo "========Initialization failed========"
                }
            }
        }
           stage("Validate and Plan Terraform"){
            steps{
               dir('terraform'){
                    echo "========Validating Terraform ========"
                    sh 'terraform validate'
                    echo "========Plan Terraform ========"
                    sh 'terraform plan -out=tfplan'
                    sh 'ls -l'
                }
            } 
            post{
                success{
                    echo "========Validation and Planned successfully========"
                }
                failure{
                    echo "========Validation and Planing failed========"
                }
               }
             }
           stage("Apply Terraform"){
            steps{
               dir('terraform'){
                    echo "========Applying Terraform ========"
                    sh 'terraform apply --auto-approve tfplan'
                    }
                 } 
            post{
                success{
                    echo "========Applied successfully========"
                }
                failure{
                    echo "========Application failed========"
                }
               }
             }
           stage("Docker build"){
            steps{
                echo "========Building Docker Image ========"
                sh 'docker build -t sanjeevprasad1983/nginx-azure-app:latest .'
                    }
                  
            post{
                success{
                    echo "========Image build successfully========"
                }
                failure{
                    echo "========Image build failed========"
                }
               }
             } 
          stage("Docker Image Verify"){
            steps{
                echo "========Verifying Docker Image ========"
                sh 'docker images'
                    }
                  
            post{
                success{
                    echo "========Image verified successfully========"
                }
                failure{
                    echo "========Image verification failed========"
                }
               }
             } 
           stage("Docker Hub Login"){
            steps{
                echo "========Login to Docker Hub ========"
                withCredentials([usernamePassword
                (credentialsId: 'Dockeruser', 
                 passwordVariable: 'dockerpass',
                 usernameVariable: 'dockeruser')]) 
                 {
                    echo "Login to docker"
                    bat 'echo %dockerpass%| docker login -u %dockeruser% --password-stdin'
                    echo "Login to docker is successful"
                }
                }
            post{
                success{
                    echo "========Login successfully========"
                }
                failure{
                    echo "========Login failed========"
                }
               }
             } 
        stage("Pushing Image"){
            steps{
                echo "========Pushing Image to Docker Hub ========"
                bat 'docker push sanjeevprasad1983/nginx-azure-app:latest'
                }
            post{
                success{
                    echo "========Login successfully========"
                }
                failure{
                    echo "========Login failed========"
                }
               }
             }
        stage("Capture public IP"){
            steps {
              dir('terraform'){
                script {
                echo "======== capturing public IP ========"
                env.VM_IP = sh(
                script: "terraform output -raw Sptechno_Public_IP",
                returnStdout: true
                ).trim()
                echo "VM IP: ${env.VM_IP}"
                } }
                }
            post{
                success{
                    echo "========public ip captured successfully========"
                }
                failure{
                    echo "========capturing failed========"
                }
               }
            } 
        stage("Login to VM") {
            steps {
                script {
                 echo "======== login VM ========"
                 // This extracts your private key safely into a temporary variable
                    withCredentials([sshUserPrivateKey(credentialsId: 'azure-vm-ssh-key', keyFileVariable: 'KEY_FILE', usernameVariable: 'SSH_USER')]) {
                        bat """
                            echo Attempting SSH connection using Jenkins-managed key...
                            ssh -i "%KEY_FILE%" -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL %SSH_USER%@${env.VM_IP} "echo Connected successfully"
                        """
                    }
                }
            }
             post {
                success {
                 echo "======== login successfully ========"
                 }
                failure {
                 echo "======== login failed ========"
                 }
                }
              }                    
        stage("Deploying Nginx Container to Azure VM") {
            steps {
                script {
                    echo "======== Deploying Nginx Container ========"
                    withCredentials([sshUserPrivateKey(credentialsId: 'azure-vm-ssh-key', keyFileVariable: 'KEY_FILE', usernameVariable: 'SSH_USER')]) {
                        bat """
                            echo Connecting to VM to deploy Nginx...
                            ssh -i "%KEY_FILE%" -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL %SSH_USER%@${env.VM_IP} "sudo docker run -d -p 80:80 --name nginx-server nginx"
                        """
                    }
                }
            }   
            post {
                success { echo "======== Deployment successfully ========" }
                failure { echo "======== Deployment failed. Check Docker logs on the VM. ========" }
            }
        }
    post {
        success {
            echo "======== Application deployed successfully! Visit http://${env.VM_IP} to view your app. ========"
        }
        failure {
            echo "======== Deployment failed. Check Docker logs on the VM. ========"
        }
    }
}
}
 
  

