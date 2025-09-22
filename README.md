# OCI DevOps-OKE-ADB Demo

This repository demonstrates an automated process for creating Oracle Cloud Infrastructure (OCI) resources using Terraform and implementing CI/CD pipelines with OCI DevOps to deploy applications to Oracle Kubernetes Engine (OKE) with an Autonomous Database (ADB) backend.

## Project Overview

The project showcases three main scenarios for infrastructure deployment and application release on OCI:

### 1. Basic Resources Preparation
- Created a GitHub repository to store Terraform scripts for different deployment scenarios
- Prepared demo project code with a web page and Python server for accessing Oracle databases

### 2. Scene 1: New Project Setup
A Terraform script that automates the creation of:
- Autonomous Database (ADB)
- Initialization of the database with SQL scripts
- Oracle Kubernetes Engine (OKE) cluster
- OCI DevOps CI and CD pipelines

### 3. Scene 2: New Application Release Version
Process for updating an existing application:
- Cloning the OCI DevOps Git repository, adding demo project code
- CI Pipeline: Building new container images
- CD Pipeline: Applying release version SQL files
- CD Pipeline: Deploying updated containers to OKE

### 4. Scene 3: New Region Deployment
A comprehensive Terraform script for multi-region deployment that:
- Creates ADB in a new region
- Applies both initialization and release version SQL files
- Creates OKE cluster
- Sets up DevOps CI/CD pipelines
- Deploys container images to the new OKE cluster

## Project Structure

```
├── terraform/           # Terraform scripts for infrastructure provisioning
│   ├── scene1/          # Resources for new project setup
│   └── scene3/          # Resources for multi-region deployment
├── app/                 # Application workload code
│   ├── web/             # Web frontend code
│   └── server/          # Python server code for database access
└── README.md            # Project documentation
```

## Getting Started

### Prerequisites
- OCI account with appropriate permissions
- Terraform installed locally
- Familiarity with OCI services (ADB, OKE, DevOps)
- Git and Docker installed

### Usage Instructions
1. Clone this repository
2. Navigate to the appropriate Terraform directory for your scenario
3. Configure your OCI credentials
4. Run `terraform init` and `terraform apply` to provision resources
5. Follow the CI/CD pipeline setup instructions in the OCI Console

## License
This project is provided for demonstration purposes only.