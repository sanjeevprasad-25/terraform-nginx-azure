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
                 sshagent(['azure-vm-ssh-key']) {
                 sh """
                 ssh -o StrictHostKeyChecking=no azureuser@${env.VM_IP} "echo 'Connected to VM successfully' "               
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
        stage("Deploy Docker Container") {
            steps {
                 script {
                    echo "======== Deploying Nginx Container to Azure VM ========"
                    sshagent(['azure-vm-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no azureuser@${env.VM_IP} "
                        # 1. Update package list and ensure Docker is running
                        sudo apt-get update -y && sudo systemctl start docker

                        # 2. Pull the latest image from Docker Hub
                        # (Replace 'your_dockerhub_username' and 'nginx-web-app' with your actual details)
                        sudo docker pull sanjeevprasad1983/nginx-azure-app:latest

                        # 3. Stop the existing container if it is already running
                        sudo docker stop my-nginx-container || true

                        # 4. Remove the old container to free up the name and port
                        sudo docker rm my-nginx-container || true

                        # 5. Run the new container mapping Port 80 on the VM to Port 80 in the container
                        sudo docker run -d -p 80:80 --name my-nginx-container sanjeevprasad1983/nginx-web-app:latest
                    "
                """
            }
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
 }    

