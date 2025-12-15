# 🌐 SimpleTimeService: Cloud-Native EKS Deployment

## 🎯 Overview

The **SimpleTimeService** is a minimal microservice built with **FastAPI** that returns the current UTC timestamp and the client's public IP address.

This project demonstrates core DevOps proficiency in:
1.  **Containerization:** Building a secure, non-root Docker image.
2.  **Infrastructure-as-Code (IaC):** Using Terraform for end-to-end cloud provisioning.
3.  **Cloud-Native Deployment:** Utilizing AWS EKS and Helm for application delivery.

## 🏛️ Architecture & Tools Used

The entire solution is deployed onto Amazon Web Services (AWS) using a secure and scalable architecture managed by Terraform.

| Component | Tool / Service | Purpose |
| :--- | :--- | :--- |
| **IaC Orchestration** | **Terraform** | Manages the entire deployment lifecycle, from VPC creation to application delivery. |
| **VPC & Network** | **AWS VPC** | Provides networking with **2 Public** and **2 Private** subnets. |
| **Container Hosting** | **AWS EKS** (Kubernetes) | Managed cluster hosting the application pods in **private subnets** for security. |
| **Application Deployment**| **Helm** (via Terraform) | Standard Kubernetes packaging mechanism for deploying the Deployment and Service. |
| **Container Image** | **Docker Hub** | Public registry hosting the application image. |
| **Service Exposure** | **AWS Network Load Balancer (NLB)** | Provides a public DNS endpoint for the application. |



---

## 💡 How the Deployment Works (Terraform Workflow)

The single `terraform apply` command executes a two-phase process. This explanation is intended for non-technical review, detailing **what** the automation is doing.

### Phase 1: Infrastructure Provisioning
Terraform first provisions the necessary cloud resources in AWS:
* **VPC and Networking:** It creates a secure, isolated network (VPC), including the private subnets where the application runs and a NAT Gateway to allow private worker nodes to pull the Docker image.
* **EKS Cluster:** It builds the entire managed Kubernetes cluster (EKS) and launches the worker nodes (the servers) into the private subnets.

### Phase 2: Application Deployment via Helm
Once the EKS cluster is ready, Terraform switches roles, using the **Helm provider** to install the application:
* **Helm Chart:** It reads the Kubernetes configuration files (Deployment, Service) defined in the Helm chart.
* **Deployment:** It tells EKS to create the application Pods using the image from Docker Hub.
* **Load Balancer:** It automatically creates an **AWS Network Load Balancer (NLB)** and connects it to the running application pods, providing the final public URL.



---

## 🛠️ Prerequisites & Setup

The following tools are mandatory for deploying and managing this project.

| Tool | Purpose | Installation Guide |
| :--- | :--- | :--- |
| **AWS CLI** | Required for configuring AWS access and connecting `kubectl` to EKS. | [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| **Terraform** | The engine for provisioning all cloud infrastructure. | [Terraform Installation](https://learn.hashicorp.com/tutorials/terraform/install-cli) |
| **Docker** | Necessary for image management and local testing. | [Docker Installation](https://docs.docker.com/get-docker/) |

### AWS Authentication

Terraform requires credentials to interact with your AWS account.

1.  Run the following command:
    ```bash
    aws configure
    ```
2.  Provide your **Access Key ID**, **Secret Access Key**, and set the desired **Default Region** (e.g., `us-east-1`).

## 📦 Application Code & Image Build

### Image Details

* **Application Code:** FastAPI on Python 3.11.
* **Container Best Practice:** The `Dockerfile` runs the application using a **non-root user (`appuser`)** for enhanced security.
* **Public Repository:** If you wish to pull the image directly, use:
    ```bash
    docker pull manidocker1248/particle41-app:latest
    ```

### 1. Local Testing (Optional)

If you wish to test the application locally before deployment, you can build and run the image using the default platform:

```bash
# From the project root directory
docker build -t local-fastapi-app ./app
docker run -d -p 8080:8080 local-fastapi-app
# Verify at http://localhost:8080/
2. EKS Production Image Build (Mandatory)
The EKS worker nodes use the AMD64 architecture. If you are building on a Mac (Apple Silicon M1/M2/M3), you must specify the target platform for compatibility.

Action: Run the following command from the project root directory to build and push the corrected image:

Bash

docker buildx build \
    --platform linux/amd64 \
    -t manidocker1248/particle41-app:latest \
    --push ./app
🚀 Deployment (Terraform Execution)
1. Review Configuration
Navigate to the terraform/ directory and ensure your terraform.tfvars file correctly specifies the image path and deployment variables.

Bash

cd terraform/
2. Initialization and Planning
Initialize Terraform (Downloads providers/modules):

Bash

terraform init
Review the Plan (Recommended best practice): This shows exactly which resources will be created before deployment.

Bash

terraform plan
3. Apply Deployment
This is the single command that provisions all cloud infrastructure and deploys the application.

(This process takes approximately 15-25 minutes.)

Bash

terraform apply --auto-approve
✅ Verification
Once terraform apply finishes, the final output will provide the public address for your application.

Retrieve Application URL Look for the application_url output value.

Access the Service Open the URL in your web browser. The service will return a JSON object confirming the timestamp and client IP.

📝 Production Readiness & Future Improvements
This service was built to satisfy the core requirements of the challenge. For a production-ready environment, the following improvements would be essential:

DevOps & Security Enhancements
Remote State Management: Implement an S3 backend for state storage and DynamoDB for state locking to prevent concurrent modification conflicts.

CI/CD Pipeline: Implement a pipeline (e.g., GitHub Actions) to automate:

Code Scanning: Run SonarQube analysis on application code upon pull requests.

Vulnerability Scanning: Use Trivy to scan the container image before pushing to Docker Hub.

Infrastructure Deployment: Run terraform plan on feature branches and terraform apply on merge to main.

Kubernetes Best Practices
Resource Limits: Add resource limits and requests to the Kubernetes Deployment to ensure stable scheduling and prevent resource starvation.

Advanced Scheduling: Use node selectors or pod affinities to schedule deployments onto specific node groups based on workload requirements (e.g., high CPU workloads on specialized nodes).

💡 Note on Generative AI
I utilized generative AI to structure the project code and documentation, prioritizing efficiency and speed. However, every component—including the non-root Docker user, the Helm-via-Terraform dependency management, the platform-specific Docker fix, and the explicit EKS networking configuration—was implemented based on my own technical knowledge and understanding of AWS and Kubernetes best practices.