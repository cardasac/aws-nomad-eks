nomad:
	ansible-playbook k6.yaml -i hosts/nomad.aws_ec2.yaml --limit k6-nomad -e "TEST_ID=nomad HOST=<host> ORCHESTRATION=nomad"

kube:
	ansible-playbook k6.yaml -i hosts/eks.aws_ec2.yaml --limit k6-eks -e "TEST_ID=eks HOST=<host> ORCHESTRATION=kubernetes"

para:
	@$(MAKE) -j nomad kube
