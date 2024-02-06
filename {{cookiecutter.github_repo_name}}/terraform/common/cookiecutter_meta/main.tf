#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2023
#
# usage: gather environment variables and add to a tags dict. This is a
#   hacky solution in that we use Bash to gather data elements, and meanwhile
#   Terraform lacks a good interface to send bash results back to the thread
#   of control.
#   as a workaround, we get bash to write its results to a file in the "output"
#   folder and then we use Terraform 'data' definitions to access each result.
#
#   But, it's worse than just that. Terraform also lacks a means of detecting
#   state changes on the null_resource objects we declare here, as this would
#   require that an 'apply' on each resource in order to run the bash code
#   contained therein. thus, it's a chicken-and-egg problem.
#
#   our workaround is:
#   1. always execute an "init" resource
#   2. inside this we rewrite the contents of cookiecutter_github_commit.state
#   3. we use a MD5 checksum of the file content of cookiecutter_github_commit.state
#      as a taint for all resources that provide data to the tags output.
#------------------------------------------------------------------------------


# ensure that a state file exists for each element we track.
resource "null_resource" "init" {
  provisioner "local-exec" {
    command = <<-EOT
    touch ${path.module}/output/cookiecutter_awscli_version.state
    touch ${path.module}/output/cookiecutter_github_branch.state
    touch ${path.module}/output/cookiecutter_github_commit_date.state
    touch ${path.module}/output/cookiecutter_github_commit.state
    touch ${path.module}/output/cookiecutter_github_repository.state
    touch ${path.module}/output/cookiecutter_iam_arn.state
    touch ${path.module}/output/cookiecutter_os.state
    touch ${path.module}/output/cookiecutter_terraform_version.state
    touch ${path.module}/output/cookiecutter_timestamp.state
    touch ${path.module}/output/cookiecutter_version.state
    EOT
  }
}

# rewrite the contents of cookiecutter_github_commit.state, which will
# taint our other resouces in the event that this changes the file
# contents.
resource "null_resource" "taint" {
  provisioner "local-exec" {
    command = <<-EOT
    GIT_PARENT_DIRECTORY=$(git rev-parse --show-toplevel)
    cookiecutter_github_commit=$(git -C $GIT_PARENT_DIRECTORY rev-parse HEAD)
    echo $cookiecutter_github_commit > ${path.module}/output/cookiecutter_github_commit.state
    EOT
  }
  triggers = {
    timestamp = "${timestamp()}"
  }
}
data "local_file" "taint" {
  filename = "${path.module}/output/cookiecutter_github_commit.state"
  depends_on = [
    null_resource.taint
  ]
}

resource "null_resource" "environment" {
  provisioner "local-exec" {
    command = <<-EOT
    # common variables
    GIT_PARENT_DIRECTORY=$(git rev-parse --show-toplevel)

    #------------------------------------------------------------------------------
    # 1. cookiecutter_awscli_version
    # get the current version of AWS CLI running on the machine that is executing
    # this module.
    #------------------------------------------------------------------------------
    cookiecutter_awscli_version=$(aws --version | awk '{print $1}' | sed 's/aws-cli//')
    cookiecutter_awscli_version=$(echo $cookiecutter_awscli_version | sed 's@/@@')
    echo $cookiecutter_awscli_version > ${path.module}/output/cookiecutter_awscli_version.state

    #------------------------------------------------------------------------------
    # 2. cookiecutter_github_branch
    # get the branch of the most recent commit
    #------------------------------------------------------------------------------
    cookiecutter_github_branch=$(git -C $GIT_PARENT_DIRECTORY branch | sed 's/* //')
    echo $cookiecutter_github_branch > ${path.module}/output/cookiecutter_github_branch.state

    #------------------------------------------------------------------------------
    # 3. cookiecutter_github_commit_date
    # get the commit date of the most recent commit from the repo containing this code
    # HINT: this will be a repo generated by the Cookiecutter (ie. {{ cookiecutter.github_repo_name }})
    #------------------------------------------------------------------------------
    cookiecutter_github_commit_date=$(date -r $(git log -1 --format=%ct) +%Y%m%dT%H%M%S)
    echo $cookiecutter_github_commit_date > ${path.module}/output/cookiecutter_github_commit_date.state

    #------------------------------------------------------------------------------
    # 4. cookiecutter_github_commit
    # get the sha of the most recent commit
    #------------------------------------------------------------------------------
    cookiecutter_github_commit=$(git -C $GIT_PARENT_DIRECTORY rev-parse HEAD)
    echo $cookiecutter_github_commit > ${path.module}/output/cookiecutter_github_commit.state

    #------------------------------------------------------------------------------
    # 5. cookiecutter_github_repository
    # get the url to the remote Github repository from which this code was cloned.
    #------------------------------------------------------------------------------
    cookiecutter_github_repository=$(git -C $GIT_PARENT_DIRECTORY config --get remote.origin.url)
    echo $cookiecutter_github_repository > ${path.module}/output/cookiecutter_github_repository.state

    #------------------------------------------------------------------------------
    # 6. cookiecutter_global_iam_arn
    # get the AWS IAM user of the key pair that AWS CLI is currently using.
    #------------------------------------------------------------------------------
    cookiecutter_global_iam_arn=$(aws sts get-caller-identity | jq -r '.["Arn"] as $v | "\($v)"')
    echo $cookiecutter_global_iam_arn > ${path.module}/output/cookiecutter_global_iam_arn.state

    #------------------------------------------------------------------------------
    # 7. REMOVED: cookiecutter_kubectl_version
    #------------------------------------------------------------------------------

    #------------------------------------------------------------------------------
    # 8. cookiecutter_os
    # get the operating system of the machine running this module
    #------------------------------------------------------------------------------
    echo $OSTYPE > ${path.module}/output/cookiecutter_os.state

    #------------------------------------------------------------------------------
    # 9. cookiecutter_terraform_version
    # get the current version of Terraform running on the machine that is executing
    # this module.
    #------------------------------------------------------------------------------
    cookiecutter_terraform_version=$(terraform --version | head -n 1 | sed 's/Terraform //')
    echo $cookiecutter_terraform_version > ${path.module}/output/cookiecutter_terraform_version.state

    #------------------------------------------------------------------------------
    # 10. cookiecutter_timestamp
    # get the system date from the machine running this module
    #------------------------------------------------------------------------------
    cookiecutter_timestamp=$(date +%Y%m%dT%H%M%S)
    echo $cookiecutter_timestamp > ${path.module}/output/cookiecutter_timestamp.state

    EOT
  }

  lifecycle {
    replace_triggered_by = [
      data.local_file.taint.id
    ]
  }

  depends_on = [
    null_resource.init
  ]
}

# 1. cookiecutter_awscli_version
data "local_file" "cookiecutter_awscli_version" {
  filename = "${path.module}/output/cookiecutter_awscli_version.state"
  depends_on = [
    null_resource.environment
  ]
}

# 2. cookiecutter_github_branch
data "local_file" "cookiecutter_github_branch" {
  filename = "${path.module}/output/cookiecutter_github_branch.state"
  depends_on = [
    null_resource.environment
  ]
}

# 3. cookiecutter_github_commit_date
data "local_file" "cookiecutter_github_commit_date" {
  filename = "${path.module}/output/cookiecutter_github_commit_date.state"
  depends_on = [
    null_resource.environment
  ]
}

# 4. cookiecutter_github_commit
data "local_file" "cookiecutter_github_commit" {
  filename = "${path.module}/output/cookiecutter_github_commit.state"
  depends_on = [
    null_resource.environment
  ]
}

# 5. cookiecutter_github_repository
data "local_file" "cookiecutter_github_repository" {
  filename = "${path.module}/output/cookiecutter_github_repository.state"
  depends_on = [
    null_resource.environment
  ]
}

# 6. cookiecutter_global_iam_arn
data "local_file" "cookiecutter_global_iam_arn" {
  filename = "${path.module}/output/cookiecutter_global_iam_arn.state"
  depends_on = [
    null_resource.environment
  ]
}

# 7. cookiecutter_kubectl_version
# removed


# 8. cookiecutter_os
data "local_file" "cookiecutter_os" {
  filename = "${path.module}/output/cookiecutter_os.state"
  depends_on = [
    null_resource.environment
  ]
}

# 9. cookiecutter_terraform_version
data "local_file" "cookiecutter_terraform_version" {
  filename = "${path.module}/output/cookiecutter_terraform_version.state"
  depends_on = [
    null_resource.environment
  ]
}

# 10. cookiecutter_timestamp
data "local_file" "cookiecutter_timestamp" {
  filename = "${path.module}/output/cookiecutter_timestamp.state"
  depends_on = [
    null_resource.environment
  ]
}

# 11. cookiecutter_version
data "local_file" "cookiecutter_version" {
  filename = "${path.module}/../../../VERSION"
}
