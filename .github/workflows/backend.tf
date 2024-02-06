terraform {
  backend "s3" {
    bucket = "assettestbuckets3"
    key    = "path/key"
    region = "us-east-1"
  }
}
