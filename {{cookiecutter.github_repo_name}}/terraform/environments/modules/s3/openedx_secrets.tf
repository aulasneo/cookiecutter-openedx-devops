#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an AWS S3 bucket to offload Open edX file storage.
#------------------------------------------------------------------------------

module "openedx_secrets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> {{ cookiecutter.terraform_aws_modules_s3 }}"

  bucket                   = var.resource_name_secrets
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/s3-bucket/aws"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_aws_modules_s3 }}"
    }
  )

  block_public_acls   = true
  block_public_policy = true

}
