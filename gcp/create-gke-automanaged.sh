#!/bin/bash
export PROJECT_NAME='devoxx-gke'
export PROJECT_ID='devoxx-2021'
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID  --format="json" | jq -r '.projectNumber')
export GCP_REGION="europe-west2"

gcloud auth login
gcloud config set project $PROJECT_ID

gcloud beta container --project "$PROJECT_ID" clusters create-auto "$PROJECT_NAME" --region "$GCP_REGION" --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GCP_REGION/subnetworks/default" --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22"

# Enable GCR
gcloud services enable containerregistry.googleapis.com

# Configure Docker
gcloud auth configure-docker
# OR
gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin https://gcr.io

# Deploy
sudo docker tag hello:1.0.16 gcr.io/$PROJECT_ID/hello:1.0.16
sudo docker push gcr.io/$PROJECT_ID/hello:1.0.16
sudo docker tag devoxx:1.0.3 gcr.io/$PROJECT_ID/devoxx:1.0.3
sudo docker push gcr.io/$PROJECT_ID/devoxx:1.0.3
sudo docker tag world:1.0.1 gcr.io/$PROJECT_ID/world:1.0.1
sudo docker push gcr.io/$PROJECT_ID/world:1.0.1

sed "s/HELLO_IMG/gcr.io\/$PROJECT_ID\/hello:1.0.16/g" docker/hello.yaml > gcp/k8s/hello.yaml
sed "s/DEVOXX_IMG/gcr.io\/$PROJECT_ID\/devoxx:1.0.3/g" docker/devoxx.yaml > gcp/k8s/devoxx.yaml
sed "s/WORLD_IMG/gcr.io\/$PROJECT_ID\/world:1.0.1/g" docker/world.yaml > gcp/k8s/world.yaml

# Enable DNS
gcloud services enable dns.googleapis.com

# Clean up
gcloud beta container  --project "$PROJECT_ID"  --region "$GCP_REGION" clusters delete "$PROJECT_NAME"