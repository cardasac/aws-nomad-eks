resource "aws_ebs_encryption_by_default" "ebs_encrypt_by_default" {
  enabled = true
}

resource "aws_ebs_snapshot_block_public_access" "block_public_access" {
  state = "block-all-sharing"
}

resource "aws_ec2_instance_metadata_defaults" "enforce_imdsv2" {
  http_tokens            = "required"
  instance_metadata_tags = "enabled"
  http_endpoint          = "enabled"
}
