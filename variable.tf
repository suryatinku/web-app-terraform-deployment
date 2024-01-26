# variable.tf

variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"  # Specify your preferred AWS region
}

variable "web_app_image" {
  description = "Docker image URL for the main web application."
  type        = string
  default     = "your-web-app-image:latest"  # Replace with your actual Docker image URL
}

variable "worker_image" {
  description = "Docker image URL for the background worker."
  type        = string
  default     = "your-worker-image:latest"  # Replace with your actual Docker image URL
}

variable "db_password" {
  description = "Password for the RDS database."
  type        = string
  default     = "your_db_password"  # Replace with your actual password
}
