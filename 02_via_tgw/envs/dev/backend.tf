terraform {
  backend "s3" {
    bucket = "tfstate-sdsator-20210410"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}