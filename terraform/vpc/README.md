<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.00 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.00 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.tf_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_vpc.tf_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | n/a | `string` | `"10.0.0.0/16"` | no |
| <a name="input_pjt_name"></a> [pjt\_name](#input\_pjt\_name) | Variable Block | `string` | `"mfk"` | no |
| <a name="input_region"></a> [region](#input\_region) | Variable Block | `string` | `"ap-northeast-2"` | no |
| <a name="input_subnets_block"></a> [subnets\_block](#input\_subnets\_block) | n/a | `string` | `"10.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->
