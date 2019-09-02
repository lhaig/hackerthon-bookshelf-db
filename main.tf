provider "aws" {
}

//--------------------------------------------------------------------
// Variables
variable "name" {}
variable "owner" {}
variable "environment_tag" {}
variable "rds_database_name" {}
variable "rds_database_password" {}
variable "rds_database_user" {}
variable "rds_identifier" {}
variable "rds_backup_window" {}
variable "rds_engine" {}
variable "rds_engine_version" {}
variable "rds_family" {}
variable "rds_iam_database_authentication_enabled" {}
variable "rds_instance_class" {}
variable "rds_maintenance_window" {}
variable "rds_major_engine_version" {}
variable "rds_port" {}

//--------------------------------------------------------------------
// Modules

data "terraform_remote_state" "vpc_id" {
  backend = "remote"
  config = {
    hostname     = "app.terraform.io"
    organization = "emea-se-playground-2019"
    workspaces = {
      name = "hackerthon-bookshelf"
    }
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.5.0"

  allocated_storage = 5
  backup_window = var.rds_backup_window
  engine = var.rds_engine
  engine_version = var.rds_engine_version
  family = var.rds_family
  iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  identifier = var.rds_identifier
  instance_class = var.rds_instance_class
  maintenance_window = var.rds_maintenance_window
  major_engine_version = var.rds_major_engine_version
  name = var.rds_database_name
  password = var.rds_database_password
  port = var.rds_port
  subnet_ids = data.terraform_remote_state.vpc_id.outputs.database_subnet_ids
  vpc_security_group_ids = [data.terraform_remote_state.vpc_id.outputs.security_group]
  username = var.rds_database_name
  tags  = {
      owner = var.owner
      env   = var.environment_tag
  }
}

output "service_endpoint" {
  value = module.rds.this_db_instance_endpoint
}
