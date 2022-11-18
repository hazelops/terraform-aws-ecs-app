package test

import (
	//"github.com/gruntwork-io/terratest/modules/random"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"io"
	"os"
	//"strings"
	"testing"
)

func CopyFileWebProxy(src, dst string) (err error) {
	sfi, err := os.Stat(src)
	if err != nil {
		return
	}
	if !sfi.Mode().IsRegular() {
		// cannot copy non-regular files (e.g., directories,
		// symlinks, devices, etc.)
		return fmt.Errorf("CopyFile: non-regular source file %s (%q)", sfi.Name(), sfi.Mode().String())
	}
	dfi, err := os.Stat(dst)
	if err != nil {
		if !os.IsNotExist(err) {
			return
		}
	} else {
		if !(dfi.Mode().IsRegular()) {
			return fmt.Errorf("CopyFile: non-regular destination file %s (%q)", dfi.Name(), dfi.Mode().String())
		}
		if os.SameFile(sfi, dfi) {
			return
		}
	}
	if err = os.Link(src, dst); err == nil {
		return
	}
	err = copyFileContentsWebProxy(src, dst)
	return
}

func copyFileContentsWebProxy(src, dst string) (err error) {
	in, err := os.Open(src)
	if err != nil {
		return
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return
	}
	defer func() {
		cerr := out.Close()
		if err == nil {
			err = cerr
		}
	}()
	if _, err = io.Copy(out, in); err != nil {
		return
	}
	err = out.Sync()
	return
}

func cleanupExamplesWebProxy(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesWebProxy(t *testing.T) {
	t.Parallel()
	// randID := strings.ToLower(random.UniqueId())
	// attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/web-nginx-proxy"

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)
	fullRootPath := rootFolder + terraformFolderRelativeToRoot

	// Copy terraform.tfvars
	fmt.Printf("Copying %s to %s\n", fullRootPath+"/terraform.tfvars", tempTestFolder+"/terraform.tfvars")
	err := CopyFileWebProxy(fullRootPath+"/terraform.tfvars", tempTestFolder+"/terraform.tfvars")
	if err != nil {
		fmt.Printf("CopyFile failed %q\n", err)
	} else {
		fmt.Printf("CopyFile succeeded\n")
	}
	dir, _ := os.ReadDir(tempTestFolder)
	for _, d := range dir {
		t.Log(d.Name())
	}
	varFiles := []string{tempTestFolder + "/terraform.tfvars"}

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
	defer cleanupExamplesWebProxy(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "10.2.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"10.2.20.0/23"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	cloudWatchLogGroup := terraform.Output(t, terraformOptions, "cloudwatch_log_group")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "examples-proxy", cloudWatchLogGroup)

	// Run `terraform output` to get the value of an output variable
	ecsClusterName := terraform.Output(t, terraformOptions, "ecs_cluster_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "examples-tftest-proxy", ecsClusterName)

	// Run `terraform output` to get the value of an output variable
	r53AppDnsName := terraform.Output(t, terraformOptions, "r53_lb_dns_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "proxy.examples.nutcorp.net", r53AppDnsName)
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
