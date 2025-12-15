# 🌐 Project: SimpleTimeService EKS Deployment

## 🎯 Project Overview and Goals

The **SimpleTimeService** is a minimal microservice built with FastAPI that returns the current UTC timestamp and the client's public IP address.

This project serves as a comprehensive demonstration of cloud-native deployment skills, covering:
* Secure Containerization
* End-to-end Infrastructure-as-Code (Terraform)
* Managed Kubernetes Deployment (AWS EKS & Helm)

### 🏛️ Architecture and Key Components

The solution provisions a secure VPC and deploys the containerized application onto AWS EKS.

| Component | Tool / Service | Purpose |
| :--- | :--- | :--- |
| **IaC Orchestration** | **Terraform** | Manages all cloud resources and orchestrates the application installation. |
| **Cloud Network** | **AWS VPC** | Provides secure networking (private subnets for workers, NAT for outbound internet). |
| **Container Orchestration**| **AWS EKS** (Kubernetes) | Managed control plane hosting the application. |
| **Application Packaging**| **Helm** | Standard packaging for deploying the Kubernetes manifests (Deployment/Service). |
| **Service Access** | **AWS Network Load Balancer (NLB)** | Automatically provisions a public endpoint for the application. |



### 💡 Deployment Workflow Explained

The entire process is automated via a single `terraform apply` command, which executes two main phases:

1.  **Infrastructure Creation:** Terraform provisions the VPC, creates the EKS cluster, and launches the necessary worker nodes.
2.  **Application Installation:** Terraform then uses the **Helm Provider** to connect to the new EKS cluster and install the application, which, in turn, provisions the final **AWS Network Load Balancer (NLB)**.

---

## 🛠️ Phase I: Setup and Preparation

### ⚠️ Prerequisites

Ensure you have the following tools installed and your AWS credentials configured:

| Tool | Installation Guide |
| :--- | :--- |
| **AWS CLI** | [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| **Terraform** | [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) |
| **Docker** | [Docker Installation Guide](https://docs.docker.com/get-docker/) |

**AWS Credentials:**

aws configure
📦 Container Image Management
The application image is hosted on Docker Hub.

Public Repository: manidocker1248/particle41-app:latest

Pull Command (Reference):


docker pull manidocker1248/particle41-app:latest
Building Your Own Image (Mandatory Fix for M-series Macs)
If you are using an Apple Silicon (M1/M2/M3) Mac, you must build the image specifically for the linux/amd64 architecture used by the AWS EKS worker nodes to avoid deployment errors.



# Run this from the project root directory
docker buildx build \
    --platform linux/amd64 \
    -t <YOUR_DOCKERHUB_USERNAME>/<YOUR_REPO_NAME>:latest \
    --push ./app
⚙️ Phase II: Configuration and Deployment
1. Mandatory Configuration Check
If you built and pushed your own image (or used a different tag), you MUST update these two files to point to your repository before deployment:

File	Variable to Change	Example of Change
terraform/terraform.tfvars	app_image_path	"myusername/my-fastapi-app:latest"
helm/fastapi-app/values.yaml	repository and tag	repository: myusername/my-fastapi-app



2. Terraform Deployment
Navigate to the terraform/ directory to begin.



cd terraform/
Step	Command	Purpose
Initialize	terraform init	Downloads providers and sets up the project.
Plan (Review)	terraform plan	Shows all infrastructure changes before applying them (Best Practice).
Apply (Deploy)	terraform apply --auto-approve	Creates the VPC, EKS Cluster, and installs the application via Helm.



✅ Phase III: Verification and Cleanup
1. Verification
The deployment is complete when terraform apply finishes.

Retrieve URL: Check the Terraform output for the application_url.

Test: Access the URL in a browser to see the JSON response (timestamp and IP).

2. Cleanup (Crucial)
To avoid recurring AWS charges, destroy all provisioned infrastructure immediately after verification.



terraform destroy --auto-approve
🌟 Additional Context: Production Strategy
This is a simple service built to satisfy core deployment requirements. For a production-ready environment, our strategy would include:

State Management: Utilizing S3 for remote Terraform state storage and DynamoDB for state locking to ensure concurrency control.

CI/CD Pipeline: Implementing automated pipelines for code quality (SonarQube), image vulnerability scanning (Trivy), and controlled deployments to EKS.

Kubernetes Hardening: Defining mandatory limits and requests for containers and using node selectors for advanced scheduling.

💡 Note on Generative AI
I used generative AI as an efficiency tool to structure and refine this documentation and the project components. The technical correctness, best practices (like non-root users, EKS networking, and the platform-specific build fix), and configuration flow were based on my own technical expertise and verification.