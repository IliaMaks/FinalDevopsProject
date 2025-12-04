# Final DevOps Project – Bank Loan Management System

Student: Ilia Maks
Student ID: 321350308
Project title: Bank Loan Management System – Full DevOps Pipeline
Repository: https://github.com/IliaMaks/FinalDevopsProject

This project implements all required components of the DevOps Final Project (application, Terraform, Ansible, Kubernetes, Helm and CI/CD with GitHub Actions).

## 1. Project Overview

This project is a Flask web application for managing:

- Bank clients
- Loans and amortization schedules
- A simple bank treasury

For the final DevOps project the application was:

- Switched from in-memory storage to file-based persistence (JSON files).
- Containerized with Docker and pushed to Docker Hub: `04unit04/final-devops-bank-app:latest`.
- Deployed to a Kubernetes cluster (3 EC2 nodes) on AWS.
- Infrastructure created with Terraform.
- Nodes configured with Ansible (Kubernetes + NFS).
- Application deployed using a Helm chart.
- Connected end-to-end with a GitHub Actions CI/CD pipeline.

On first start the app creates dummy data, so the UI is ready immediately.

## 2. How to Get the Code

```bash
git clone https://github.com/IliaMaks/FinalDevopsProject.git
cd FinalDevopsProject
```

Main components:

- **Application** – `Website/app.py`, `Pythoncode/functions.py`, `Website/templates/`, `Website/static/`
- **Docker** – `Dockerfile`, `.dockerignore`
- **Terraform** – `terraform/`
- **Ansible** – `ansible/`
- **Helm chart** – `K8s/helm/bank-app/`
- **CI/CD workflow** – `.github/workflows/cicd.yml`

## 3. Required Tools

For running the CI/CD pipeline (GitHub runner + AWS):

Accounts / services:

- AWS account (for EC2, VPC, Load Balancer).
- Existing EC2 key pair named `vockey` in the chosen region (default: `us-east-1`).
- Docker Hub account `04unit04` (image repository owner).
- GitHub repository with this project.

Tools (used inside the GitHub runner; no need to install on your PC):

- Python 3.11
- Docker
- Terraform ≥ 1.2
- Ansible
- `kubectl`
- `helm`

## 4. GitHub Secrets and AWS Credentials

All sensitive data is passed through GitHub Actions Secrets.

In the repository go to: **Settings → Secrets and variables → Actions** and create:

- `AWS_ACCESS_KEY_ID` – AWS access key
- `AWS_SECRET_ACCESS_KEY` – AWS secret key
- `AWS_SESSION_TOKEN` – session token (AWS Academy / temporary credentials)
- `AWS_REGION` – e.g. `us-east-1`
- `AWS_SSH_KEY` – contents of the private key `vockey.pem`  
  Copy the full text, including `-----BEGIN` / `-----END` lines.
- `DOCKERHUB_TOKEN` – Docker Hub access token for user `04unit04`  
  The value is provided in `TOKEN.txt` inside the ZIP file from Moodle.

## 5. How to Trigger the CI/CD Pipeline

- Workflow file: `.github/workflows/cicd.yml`
- Workflow name: `CI-CD Final DevOps Project`

Manual run steps:

1. Make sure all secrets from section 4 are configured.
2. Go to the **Actions** tab in GitHub.
3. Select **CI-CD Final DevOps Project**.
4. Click **Run workflow** (branch `master`).
5. Wait until job `build-test-deploy` finishes.

## 6. Pipeline Stages (CI/CD Workflow)

The main job `build-test-deploy` runs on `ubuntu-latest` and performs the following stages:

1. Checkout repository
2. Set up Python
3. Run unit tests
4. Build Docker image
5. Login to Docker Hub
6. Push Docker image
7. Install Terraform
8. Terraform Init
9. Terraform Destroy  
   (cleanup previous run – and yes, I know that in this student setup it’s a bit pointless, because without a remote `tfstate` in S3 the next GitHub runner has no idea about the old resources, so it won’t really “magically” delete the previous infrastructure… but in a real pipeline with shared `tfstate` this step would save a lot of time.)
10. Terraform Apply (create VPC, EC2 instances and Load Balancer)
11. Write SSH key for Ansible
12. Generate Ansible inventory (master + workers)
13. Show generated inventory
14. Install Ansible
15. Run Ansible playbook – Kubernetes basic setup
16. Run Ansible playbook – NFS server
17. Run Ansible playbook – init cluster & join workers
18. Deploy bank app via Helm
19. Show application URL (ALB DNS)

## 7. How to Find the Load Balancer URL

After a successful run:

1. Open the workflow run in the **Actions** tab.
2. Scroll to the step **Show application URL**.
3. In the logs you will see: `Application URL: http://<ALB_DNS>/`.
4. Open this URL in a browser.

The ALB listens on port 80 and forwards requests to the Kubernetes Service (NodePort `30080` → pod port `5000`).

## 8. Troubleshooting

Common issues:

- **Pipeline fails on Terraform**  
  - Check AWS secrets and IAM permissions.
- **Ansible cannot connect to hosts**  
  Verify:  
  - EC2 key pair name in AWS is `vockey`.  
  - `AWS_SSH_KEY` contains the correct private key.  
  - Security group allows SSH (`22/tcp`).
- **Docker push fails**  
  - `DOCKERHUB_TOKEN` must be a valid token for user `04unit04`.

Logs:

- CI/CD – GitHub → Actions → run details
- Terraform – steps “Terraform Init / Destroy / Apply”
- Ansible – steps with `ansible-playbook`

## 9. Application User Guide

A separate document with end-user instructions is provided in `user-guide.md`:

- How to use the web UI
- Available features
- Explanation of main pages and flows

