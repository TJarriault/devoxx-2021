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
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

eksctl create cluster --auto-kubeconfig  -f aws-cluster-eks.yaml

# Check IP on Security Groups
aws eks --region $AWS_REGION  update-kubeconfig --name  $EKS_CLUSTER_NAME

aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
aws ecr create-repository --repository-name devoxx2021/hello --image-scanning-configuration scanOnPush=true --image-tag-mutability IMMUTABLE
aws ecr create-repository --repository-name devoxx2021/devoxx --image-scanning-configuration scanOnPush=true --image-tag-mutability IMMUTABLE
aws ecr create-repository --repository-name devoxx2021/world --image-scanning-configuration scanOnPush=true --image-tag-mutability IMMUTABLE

sudo docker tag hello:1.0.16 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/devoxx2021/hello:1.0.16
sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/devoxx2021/hello:1.0.16
sudo docker tag devoxx:1.0.3 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/devoxx2021/devoxx:1.0.3
sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/devoxx2021/devoxx:1.0.3
sudo docker tag world:1.0.1 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/devoxx2021/world:1.0.1
sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/devoxx2021/world:1.0.1

sed "s/HELLO_IMG/$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com\/devoxx2021\/hello:1.0.16/g" docker/hello.yaml > aws/k8s/hello.yaml
sed "s/DEVOXX_IMG/$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com\/devoxx2021\/devoxx:1.0.3/g" docker/devoxx.yaml > aws/k8s/devoxx.yaml
sed "s/WORLD_IMG/$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com\/devoxx2021\/world:1.0.1/g" docker/world.yaml > aws/k8s/world.yaml

kubectl apply -f aws/k8s

# eksctl delete cluster -f aws/aws-cluster-eks.yaml