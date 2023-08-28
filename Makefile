kubeconfig-get:
	terraform output -raw kubeconfig > kubeconfig.yml

infracost:
	infracost breakdown --path . --show-skipped
