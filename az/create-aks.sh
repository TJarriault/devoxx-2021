export RESOURCE_GROUP='devoxx-2021'
export AZ_REGION='francecentral'

# Create resource group
az group create --name $RESOURCE_GROUP --location $AZ_REGION
# Create Container Registry
export ACR='devoxxTestOdu'
az acr create --resource-group $RESOURCE_GROUP --name ${ACR} --sku Basic

export DEPLOYMENT_NAME='devoxx-deployment'
az deployment group create -g $RESOURCE_GROUP -n $DEPLOYMENT_NAME --template-file template.json --parameters @parameters.json

# Login into ACR
TOKEN=$(az acr login --name $ACR --expose-token --output tsv --query accessToken)
sudo docker login $ACR.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password $TOKEN

sudo docker tag hello:1.0.16 $ACR.azurecr.io/devoxx2021/hello:1.0.16
sudo docker push $ACR.azurecr.io/devoxx2021/hello:1.0.16
sudo docker tag devoxx:1.0.3 $ACR.azurecr.io/devoxx2021/devoxx:1.0.3
sudo docker push $ACR.azurecr.io/devoxx2021/devoxx:1.0.3
sudo docker tag world:1.0.1 $ACR.azurecr.io/devoxx2021/world:1.0.1
sudo docker push $ACR.azurecr.io/devoxx2021/world:1.0.1

# Login to AKS
export AKS_CLUSTER='devoxx-aks'
az aks get-credentials --name $AKS_CLUSTER --resource-group $RESOURCE_GROUP --admin

sed "s/HELLO_IMG/$ACR.azurecr.io\/devoxx2021\/hello:1.0.16/g" docker/hello.yaml > az/k8s/hello.yaml
sed "s/DEVOXX_IMG/$ACR.azurecr.io\/devoxx2021\/devoxx:1.0.3/g" docker/devoxx.yaml > az/k8s/devoxx.yaml
sed "s/WORLD_IMG/$ACR.azurecr.io\/devoxx2021\/world:1.0.1/g" docker/world.yaml > az/k8s/world.yaml

kubectl apply -f az/k8s

az group delete --name $RESOURCE_GROUP