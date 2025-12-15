## 🌐 SimpleTimeService on AWS EKS

**SimpleTimeService** is a small FastAPI service that returns the current UTC timestamp and the client's IP address.  
This repo shows an end-to-end, cloud‑native deployment to **AWS EKS** using **Terraform** and **Helm**.

### 🏛️ Architecture

The Terraform code provisions networking and a Kubernetes cluster, then deploys the containerized app via Helm:

| **Component**           | **Tool / Service**     | **Purpose**                                                        |
|-------------------------|------------------------|--------------------------------------------------------------------|
| IaC orchestration       | Terraform              | Provisions all AWS resources and installs the app via Helm        |
| Cloud network           | AWS VPC                | Private subnets, NAT gateway, secure networking                    |
| Kubernetes control plane| AWS EKS                | Managed Kubernetes cluster                                         |
| App packaging           | Helm                   | Defines Deployment, Service, and related Kubernetes resources      |
| External access         | AWS Network LB (NLB)   | Public endpoint for the FastAPI service                            |

The `terraform` code is configured by default for **region `us-east-1`** and image path defined in `terraform.tfvars`.

---

## 💻 Running the app locally (optional)

From the project root:

```bash
cd app
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

Call the service:

```bash
curl http://localhost:8000/
```

You should see a JSON response similar to:

```json
{
  "timestamp": "2025-01-01T12:00:00+00:00",
  "ip": "127.0.0.1"
}
```

Health endpoints:

- `GET /health` – liveness
- `GET /ready` – readiness

---

## 🛠️ Phase I – Prerequisites

Install and configure:

| **Tool**   | **Guide** |
|-----------|-----------|
| AWS CLI   | [AWS CLI install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| Terraform | [Terraform install](https://learn.hashicorp.com/tutorials/terraform/install-cli)        |
| Docker    | [Docker install](https://docs.docker.com/get-docker/)                                  |

Configure AWS credentials (must be able to create VPC, EKS, IAM, NLB, etc.):

```bash
aws configure
```

---

## 📦 Container image

**Default image (already configured):**

- `docker.io/manidocker1248/particle41-app:latest`

Pull for reference:

```bash
docker pull manidocker1248/particle41-app:latest
```

### Apple Silicon (M1/M2/M3) users – build `linux/amd64`

Kubernetes worker nodes on EKS are `linux/amd64` by default (unless you explicitly use ARM/Graviton node groups), so on Apple Silicon you **must** build and push an `amd64` image:

```bash
# From project root
docker buildx build \
  --platform linux/amd64 \
  -t <YOUR_DOCKERHUB_USERNAME>/<YOUR_REPO_NAME>:latest \
  --push ./app
```

Then update the image references as shown below.

---

## ⚙️ Phase II – Configure and deploy

### 1️⃣ Update configuration (if using your own image)

If you built and pushed your own image or tag, update:

| **File**                      | **Field(s) to change** | **Example**                                      |
|-------------------------------|------------------------|--------------------------------------------------|
| `terraform/terraform.tfvars`  | `app_image_path`       | `"myusername/my-fastapi-app:latest"`             |
| `helm/fastapi-app/values.yaml`| `repository`, `tag`    | `repository: myusername/my-fastapi-app`          |

You can also adjust other values in `terraform.tfvars` such as `aws_region`, `project_name`, `vpc_cidr`.

### 2️⃣ Deploy with Terraform

From the project root:

```bash
cd terraform

# Initialize providers and modules
terraform init

# Review planned changes (recommended)
terraform plan

# Create VPC, EKS, and install the app via Helm
terraform apply --auto-approve
```

Terraform will:

- Create the VPC, subnets, security groups, and EKS cluster
- Provision worker nodes
- Use the Helm provider to install the `fastapi-app` chart
- Expose the service via an AWS Network Load Balancer

---

## ✅ Phase III – Verify and clean up

### Verify

After `terraform apply` completes:

1. Check the Terraform output for `application_url`.
2. Open the URL in a browser or use `curl` to confirm the JSON response (`timestamp` + `ip`).

### Clean up (important)

To avoid ongoing AWS charges, destroy all resources when done:

```bash
cd terraform
terraform destroy --auto-approve
```

---

## 🧩 Troubleshooting (quick tips)

- **No response / 5xx from URL**  
  - Check Kubernetes objects (after configuring `kubectl` for the EKS cluster):  
    ```bash
    kubectl get pods,svc
    ```
  - Ensure the service is of type `LoadBalancer` and pods are `Running`.

- **Apple Silicon image / architecture errors**  
  - Verify your image is built with `--platform linux/amd64` and that `terraform.tfvars` and Helm values point to that image.

- **Terraform permission or region issues**  
  - Confirm `aws_region` in `terraform/terraform.tfvars` matches your target region and that your AWS user/role has permissions for VPC, EKS, IAM, and ELB.

---

## 🌟 Production‑readiness notes

For a production setup, you would typically add:

- **Remote Terraform state**: S3 backend + DynamoDB lock table.
- **CI/CD**: Here in this project docker image has been built and pushed manually to the contianer repository. But i usually use cicd in production to check the code with sonarqube before it get merged to main and then to build the image  and then  test the image with trivyscan before pushing and then pushing and deploying the image on eks. 
- **Kubernetes hardening**: Resource limits/requests, non‑root containers, network policies, and node selectors/taints where appropriate.

*Generative AI was used to help structure documentation, but the technical design (networking, image build strategy, EKS setup) was validated manually.* 