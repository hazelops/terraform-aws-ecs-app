package test

import (
	//"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"os"
	//"strings"
	"testing"
)

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesCompleteWeb(t *testing.T) {
	t.Parallel()
	// randID := strings.ToLower(random.UniqueId())
	// attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete-web"
	varFiles := []string{"terraform.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		/*Vars: map[string]interface{}{
			"attributes": attributes,
		},
		*/
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "10.30.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"10.30.20.0/23", "10.30.22.0/23", "10.30.24.0/23"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	cloudWatchLogGroup := terraform.Output(t, terraformOptions, "cloudwatch_log_group")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "examples-app", cloudWatchLogGroup)

	// Run `terraform output` to get the value of an output variable
	ecsClusterName := terraform.Output(t, terraformOptions, "ecs_cluster_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "examples-complete-web", ecsClusterName)

	// Run `terraform output` to get the value of an output variable
	r53AppDnsName := terraform.Output(t, terraformOptions, "r53_lb_dns_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "app.examples.nutcorp.net", r53AppDnsName)
	/*
		// Run `terraform output` to get the value of an output variable
		proxyEndpoint := terraform.Output(t, terraformOptions, "proxy_endpoint")
		// Verify we're getting back the outputs we expect
		assert.Contains(t, proxyEndpoint, "eg-test-rds-proxy-"+randID)

		// Run `terraform output` to get the value of an output variable
		proxyTargetEndpoint := terraform.Output(t, terraformOptions, "proxy_target_endpoint")
		instanceAddress := terraform.Output(t, terraformOptions, "instance_address")
		// Verify we're getting back the outputs we expect
		assert.Equal(t, proxyTargetEndpoint, instanceAddress)
	*/
}