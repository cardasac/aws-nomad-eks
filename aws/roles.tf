resource "aws_iam_instance_profile" "instance_profile" {
  name = "nomad-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name               = "nomad-role"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "nomad-auto-discover-cluster"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment_instance_profile_power_user" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_cloudwatch_agent_server" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_caller_identity" "current" {}


resource "aws_iam_role_policy_attachment" "policy_attachment_image_builder_full_access" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSImageBuilderFullAccess"
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:DescribeParameters", "ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/AmazonCloudWatch-*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
      "secretsmanager:GetSecretValue",
      "appconfig:GetLatestConfiguration",
      "appconfig:StartConfigurationSession",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_instance_profile" "instance_profile_packer" {
  name = "packer-instance-profile"
  role = aws_iam_role.instance_role_packer.name
}

resource "aws_iam_role" "instance_role_packer" {
  name               = "packer-role"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

resource "aws_iam_role_policy_attachment" "managed_instance_core" {
  role       = aws_iam_role.instance_role_packer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
