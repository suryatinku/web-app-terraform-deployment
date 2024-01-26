# Web Application Deployment Stack using Terraform

This Terraform configuration sets up a deployment stack for a web application on AWS, comprising two services: a main web application and a background worker. It uses ECS (Elastic Container Service) for container orchestration and RDS (Relational Database Service) for the database.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
2. AWS account credentials configured.

## Usage

1. Clone this repository.
2. Modify the configuration files as needed.
3. Run the following commands:

```bash
terraform init
terraform apply
