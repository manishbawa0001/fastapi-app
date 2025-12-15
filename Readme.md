# 🌐 SimpleTimeService: Cloud-Native EKS Deployment

## 🎯 Project Phase I: Overview and Architecture

This phase introduces the application, the components used, and the overall deployment strategy.

### 1. Application Overview

The **SimpleTimeService** is a minimal microservice built with **FastAPI** that returns the current UTC timestamp and the client's public IP address.

### 2. Tools and Technologies

The project demonstrates proficiency across the cloud-native toolchain:

| Component | Tool / Service | Purpose |
| :--- | :--- | :--- |
| **IaC Orchestration** | **Terraform** | Manages the entire cloud infrastructure setup (VPC, EKS, Load Balancer). |
| **Container Hosting** | **AWS EKS** (Kubernetes) | Managed cluster hosting the application securely. |
| **Application Packaging**| **Helm** (via Terraform) | Standard packaging mechanism for deploying Kubernetes manifests. |
| **Image Registry** | **Docker Hub** | Public repository hosting the container image. |

### 3. How the Infrastructure Connects (The Workflow)

The deployment is fully automated through a dependency chain managed by Terraform.

1.  **Infrastructure Provisioning:** Terraform first creates the secure network (**VPC**), including the **private subnets** where the application runs, and the **EKS Cluster**.
2.  **Application Deployment:** Once the cluster is ready, Terraform uses the **Helm provider** to install the application.
3.  **Service Exposure:** The Helm chart automatically provisions an **AWS Network Load Balancer (NLB)**, providing the final public URL that connects to the application pods running inside EKS.



---

## 📦 Project Phase II: Image Build and Preparation

This phase details how the application code is turned into a container and made accessible to the cloud environment.

### 1. Ready-to-Use Image

The final, tested application image is already publicly available on Docker Hub for immediate deployment.

* **Public Repository:** `manidocker1248/particle41-app:latest`
* **Pull Command (for reference):**
    ```bash
    docker pull manidocker1248/particle41-app:latest
    ```

### 2. If You Need to Build Your Own Image

If you modify the application code, you must rebuild and push the container image.

* **Crucial Note (Platform Compatibility):** AWS EKS worker nodes use the **AMD64** architecture. If you are building on a Mac with an M1/M2/M3 chip, you **must** specify the target platform using `docker buildx`.

**Action:** Run this command from the project root directory (where the `app` folder is):

```bash
docker buildx build \
    --platform linux/amd64 \
    -t manidocker1248/particle41-app:latest \
    --push ./app
🚀 Project Phase III: Deployment and Management
This phase outlines the prerequisites, the deployment commands, and the verification steps.

1. Prerequisites and Setup
Ensure you have the following tools installed and your AWS environment configured:

AWS CLI, Terraform, and Docker are installed.

AWS Credentials Configured:

Bash

aws configure
2. Deployment Process
The deployment requires only two Terraform steps executed from the terraform/ directory.

Initialize and Review Plan (Recommended best practice):

Bash

cd terraform/
terraform init      # Downloads necessary modules and providers
terraform plan      # Shows exactly what will be created
Execute Deployment (Provisions all resources): This command creates the VPC, EKS cluster, and deploys the application.

(This process takes approximately 15-25 minutes.)

Bash

terraform apply --auto-approve
3. Verification
Once terraform apply finishes, the final output will provide the public address for your application.

Retrieve Application URL: Look for the application_url output value.

Access the Service: Open the URL in your web browser.

4. Cleanup (Mandatory)
To prevent incurring unnecessary AWS costs, you must destroy all resources immediately after verification.

Run the Destroy Command (from the terraform/ directory):

Bash

terraform destroy --auto-approve
🌟 Additional Context: Production Readiness
This is a simple service built to serve the project demonstration purpose. For a professional, production-recommended solution, several essential features would be implemented:

Resource Management: Adding Kubernetes limits and requests to the Deployment for stable scheduling.

Advanced Scheduling: Using node selectors or pod affinities to schedule deployments on specific nodes based on workload.

CI/CD Pipeline Integration:

Implementing a pipeline on pull requests to run code checks (e.g., SonarQube).

Running image vulnerability scans (e.g., Trivy) before pushing to the container registry.

Terraform State Security: Configuring a remote backend using S3 for state storage and DynamoDB for state locking to prevent conflicts during concurrent operations.

💡 Note on Generative AI
I utilized generative AI to structure the project code and documentation, prioritizing efficiency and speed. However, every component—including the non-root Docker user, the Helm-via-Terraform dependency management, the platform-specific Docker fix, and the explicit EKS networking configuration—was implemented based on my own technical knowledge and understanding of AWS and Kubernetes best practices.