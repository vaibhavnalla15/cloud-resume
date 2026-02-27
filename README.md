# Cloud Resume Challenge (AWS)  
**Serverless Architecture · Terraform · CI/CD · GitHub Actions**

---

## 📌 Overview

This project is an end-to-end implementation of the **Cloud Resume Challenge (AWS)**, built to demonstrate **real-world cloud engineering and DevOps practices**.

The application consists of a static resume frontend served globally via a CDN, backed by a serverless API that tracks visitor count. The entire infrastructure is managed using **Infrastructure as Code (Terraform)**, and frontend deployments are automated using **CI/CD with GitHub Actions**.

> **Important Note**  
> The infrastructure was intentionally **destroyed after successful validation using Terraform** to avoid unnecessary cloud costs.  
> The project is **fully reproducible** from this repository at any time.

---

## 🏗️ Architecture

### High-Level Flow

1. User accesses the resume through **Amazon CloudFront**
2. CloudFront serves static content from **Amazon S3**
3. Frontend JavaScript calls an **API Gateway (HTTP API)** endpoint
4. API Gateway invokes **AWS Lambda (Python)**
5. Lambda updates and retrieves the visitor count from **Amazon DynamoDB**
6. Visitor count is returned and rendered on the resume page

### AWS Services Used

- **Amazon S3** – Static website hosting  
- **Amazon CloudFront** – CDN with HTTPS  
- **Amazon API Gateway (HTTP API)** – Serverless API  
- **AWS Lambda (Python)** – Backend logic  
- **Amazon DynamoDB** – Visitor counter persistence  
- **AWS IAM** – Secure access control  

---

## 🧰 Tech Stack

| Category | Technologies |
|-------|-------------|
| Cloud | AWS (S3, CloudFront, Lambda, DynamoDB, API Gateway, IAM) |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Backend | Python (AWS Lambda) |
| Frontend | HTML, JavaScript |
| Version Control | Git, GitHub |

---

## 📁 Repository Structure
```
cloud-resume-challenge/
├── frontend/
│   └── index.html
├── backend/
│   └── lambda/
│       └── visitor_counter.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── lambda/
│   │   └── visitor_counter.py
│   └── frontend/
│       └── index.html
└── .github/
    └── workflows/
        └── deploy.yml
```

## 🖼️ Project Screenshots

### Resume Homepage
![Resume Homepage](assets/images/ss-1.png)

### Visitor Counter in Action
![Visitor Counter](assets/images/ss-2.png)


---

## 🚀 Infrastructure Provisioning (Terraform)

All infrastructure is managed using **Terraform**, which serves as the **single source of truth**.

### Resources Managed by Terraform

- S3 bucket with static website hosting
- CloudFront distribution
- DynamoDB table (`visitor-count`)
- Lambda function (Python runtime)
- API Gateway (HTTP API)
- IAM roles and policies

### Infrastructure Lifecycle

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```
---

- Existing manually created AWS resources were imported into Terraform state
- Infrastructure drift was eliminated before final validation
- Full teardown performed using terraform destroy

---

# 🔁 CI/CD Pipeline (GitHub Actions)

### Frontend deployments are automated using GitHub Actions.

#### Trigger Conditions
Push to the main branch
Changes under:
```
frontend/**
```
---

### Pipeline Steps

1. GitHub provisions a temporary runner

2. Repository code is checked out

3. AWS credentials are injected securely via GitHub Secrets

4. Frontend files are synced to Amazon S3

5. CloudFront cache is invalidated automatically

### Outcome

1. Zero manual deployments

2. No stale cached content

3. Consistent and repeatable releases

---

### 🧪 Verification & Testing

1. The project was fully validated before cleanup:

2. Resume accessible via CloudFront HTTPS URL

3. Visitor counter increments on each page refresh

4. API Gateway /count endpoint returns correct JSON

5. Lambda performs atomic updates to DynamoDB

6. Terraform plan shows a clean, drift-free state

7. GitHub Actions pipeline completes successfully (green)

---

### 🧹 Cleanup Strategy

- To maintain cost efficiency:

    - All AWS resources were deleted using Terraform

    - No resources were removed manually via AWS Console

    - Infrastructure can be recreated at any time using IaC

    - This approach reflects production-grade lifecycle management.

---

### 🎯 Key Learnings

1. Designing serverless architectures on AWS

2. Managing infrastructure with Terraform
 
3. Importing existing resources into Terraform state

4. Implementing CI/CD with GitHub Actions

5. Handling CloudFront caching and invalidation

7. Applying cost-conscious cleanup strategies

---

## 📌 Resume-Ready Summary

Designed and deployed a serverless cloud resume on AWS, automated infrastructure using Terraform, implemented CI/CD with GitHub Actions, and managed the full infrastructure lifecycle including validation and teardown.

---

### 🔮 Possible Enhancements

1. Custom domain using Route 53

2. Terraform modules for reusability

3. Least-privilege IAM policies for CI/CD

4. Backend CI/CD for Lambda

5. Monitoring with CloudWatch dashboards

---

### 🏁 Final Note

This project demonstrates real-world cloud engineering practices —
from architecture design and automation to validation and responsible cleanup.

It is fully reproducible, cost-efficient, and production-aligned.