# get your account ID
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')

# define a role trust policy that opens the role to users in your account (limited by IAM policy)
POLICY=$(echo -n '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':root"},"Action":"sts:AssumeRole","Condition":{}}]}')

# create a role named KubernetesAdmin (will print the new role's ARN)
aws iam create-role \
  --role-name KubernetesAdmin \
  --description "Kubernetes administrator role (for AWS IAM Authenticator for Kubernetes)." \
  --assume-role-policy-document "$POLICY" \
  --output text \
  --query 'Role.Arn'



go get -u -v sigs.k8s.io/aws-iam-authenticator/cmd/aws-iam-authenticator

export AWS_REGION='eu-west-1'
export EKS_CLUSTER_NAME='devoxx2021-cluster'

# Check IP on Security Groups

aws eks --region $AWS_REGION  update-kubeconfig --name  $EKS_CLUSTER_NAME