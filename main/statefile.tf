terraform {
  backend "s3" {
    # bucket  = "ezycloud001"
    # key     = "infra.tfstate"
    # region  = "eu-west-2"
    # profile = "default"
    # Don't specify actual values here - they will be provided via -backend-config
    # during terraform init
    
    # Explicitly disable profile usage
    profile = ""
    
    # Skip validations that might try to use profiles
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    
    
  }
}

