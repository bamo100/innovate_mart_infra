# Retail Store & EKS Infrastructure (Capstone Project)

Welcome to the main entry point for the **Retail Store Capstone Project** monorepo. This repository contains both the infrastructure provisioning code and the sample application source code.

## 📁 Repository Structure

This monorepo is divided into two primary sub-projects:

*   ### [💻 Retail Store Application (retail-store-sample-app)](./retail-store-sample-app)
    Contains the frontend and backend microservices code (UI, Carts, Catalog, Checkout, Orders) as well as the Helm charts used for deploying them.
    *   👉 Refer to the [Application README](./retail-store-sample-app/README.md) for details on running the application locally.

*   ### [🏗️ EKS Infrastructure (innovartMart-infra)](./innovartMart-infra)
    Contains the Terraform configurations to provision the AWS cloud infrastructure (VPC, EKS, RDS databases, DynamoDB, IAM, S3, OIDC, and Serverless extensions).
    *   👉 Refer to the [Infrastructure README](./innovartMart-infra/README.md) for steps to deploy or tear down the environment.

---

## 🚀 Getting Started

To get this project running in your own AWS account:

1.  **Provision the Infrastructure:** Follow the deployment guide inside the [innovartMart-infra README](./innovartMart-infra/README.md).
2.  **Deploy the Application:** Use the `deploy.sh` script inside the `innovartMart-infra/kubernetes` folder to deploy the microservices onto your newly provisioned EKS cluster.
