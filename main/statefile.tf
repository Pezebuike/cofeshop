terraform {
  backend "s3" {
    bucket  = "ezycloud001"
    key     = "infra.tfstate"
    region  = "eu-west-2"
    profile = "default"
    
  }
}