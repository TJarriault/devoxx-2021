#!/bin/bash
export PROJECT_ID='devoxx-2021'
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID  --format="json" | jq -r '.projectNumber')

gcloud auth login
gcloud config set project $PROJECT_ID

cd docker/hello
# gcloud builds submit --tag gcr.io/$(echo $PROJECT_ID)/helloworld
# gcloud builds submit --config=gcp/cloud-build.yaml --substitutions=_IMAGE_NAME="hello",_DOCKERFILE_PATH="docker/hello" 
# gcloud builds submit --config=gcp/cloud-build.yaml --substitutions=_IMAGE_NAME="devoxx",_DOCKERFILE_PATH="docker/devoxx" 
# gcloud builds submit --config=gcp/cloud-build.yaml --substitutions=_IMAGE_NAME="world",_DOCKERFILE_PATH="docker/world" 

# Enable Cloud Run Admin for Cloud Run in https://console.cloud.google.com/cloud-build/settings/service-account?project=devoxx-2021&folder=&organizationId=
export SERVICE_IDENTITY="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
export SERVICE_ACCOUNT="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
export SERVICE_ROLE="roles/iam.serviceAccountUser"
gcloud iam service-accounts add-iam-policy-binding \
  ${SERVICE_IDENTITY} \
  --member="${SERVICE_ACCOUNT}" \
  --role="${SERVICE_ROLE}"
export SERVICE_ROLE="roles/run.admin"
gcloud projects  add-iam-policy-binding \
  ${PROJECT_ID} \
  --member="${SERVICE_ACCOUNT}" \
  --role="${SERVICE_ROLE}"
# Build, push and deploy
gcloud builds submit --config=gcp/cloud-build.yaml --substitutions=_IMAGE_NAME="hello",_DOCKERFILE_PATH="docker/hello"
gcloud builds submit --config=gcp/cloud-build.yaml --substitutions=_IMAGE_NAME="devoxx",_SERVICE_NAME="devoxx",_DOCKERFILE_PATH="docker/devoxx"
gcloud builds submit --config=gcp/cloud-build.yaml --substitutions=_IMAGE_NAME="world",_SERVICE_NAME="world",_DOCKERFILE_PATH="docker/world"

gcloud run services delete hello --region europe-west2 --platform managed
gcloud run services delete devoxx --region europe-west2 --platform managed
gcloud run services delete world --region europe-west2 --platform managed