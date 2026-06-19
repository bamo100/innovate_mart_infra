#!/bin/bash
set -e

NAMESPACE="retail-app"
PROJECT_NAME="project-bedrock"
# Path to the helm chart in the other repository
CHART_DIR="./retail-store-sample-app/src/app/chart"

echo "=========================================="
echo " Starting Retail Store Deployment to EKS  "
echo "=========================================="

# 1. Connect to EKS Cluster
echo "[1/5] Updating kubeconfig for ${PROJECT_NAME}-cluster..."
aws eks update-kubeconfig --name ${PROJECT_NAME}-cluster --region us-east-1

# 2. Create the retail-app namespace
echo "[2/5] Ensuring namespace '${NAMESPACE}' exists..."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# 3. Retrieve DB credentials securely from AWS Secrets Manager
echo "[3/5] Retrieving secure credentials from Secrets Manager..."
MYSQL_SECRET=$(aws secretsmanager get-secret-value --secret-id ${PROJECT_NAME}/mysql-credentials --region us-east-1 --query SecretString --output text)
POSTGRES_SECRET=$(aws secretsmanager get-secret-value --secret-id ${PROJECT_NAME}/postgres-credentials --region us-east-1 --query SecretString --output text)

MYSQL_USER=$(echo $MYSQL_SECRET | python3 -c "import sys, json; print(json.load(sys.stdin)['username'])")
MYSQL_PASS=$(echo $MYSQL_SECRET | python3 -c "import sys, json; print(json.load(sys.stdin)['password'])")
MYSQL_HOST=$(echo $MYSQL_SECRET | python3 -c "import sys, json; print(json.load(sys.stdin)['host'])")

POSTGRES_USER=$(echo $POSTGRES_SECRET | python3 -c "import sys, json; print(json.load(sys.stdin)['username'])")
POSTGRES_PASS=$(echo $POSTGRES_SECRET | python3 -c "import sys, json; print(json.load(sys.stdin)['password'])")
POSTGRES_HOST=$(echo $POSTGRES_SECRET | python3 -c "import sys, json; print(json.load(sys.stdin)['host'])")

# 4. Inject into Kubernetes Secrets
echo "[4/5] Injecting credentials into Kubernetes Secrets (never committed to git)..."
kubectl create secret generic db-credentials-mysql \
  --namespace ${NAMESPACE} \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USER=${MYSQL_USER} \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_PASSWORD=${MYSQL_PASS} \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic db-credentials-postgres \
  --namespace ${NAMESPACE} \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_USERNAME=${POSTGRES_USER} \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_PASSWORD=${POSTGRES_PASS} \
  --dry-run=client -o yaml | kubectl apply -f -
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_ARN=$(cd "${SCRIPT_DIR}/.." && terraform output -raw acm_certificate_arn)

# 5. Deploy Helm Chart with Injected Endpoints
echo "[5/5] Injecting RDS endpoints and deploying Helm chart..."
sed -e "s/TO_BE_REPLACED_MYSQL_ENDPOINT/${MYSQL_HOST}/g" \
    -e "s/TO_BE_REPLACED_POSTGRES_ENDPOINT/${POSTGRES_HOST}/g" \
    -e "s|TO_BE_REPLACED_CERT_ARN|${CERT_ARN}|g" \
    kubernetes/values-production.yaml > kubernetes/values-injected.yaml

echo "Updating Helm dependencies..."
helm dependency update ${CHART_DIR}

helm upgrade --install retail-store ${CHART_DIR} \
  --namespace ${NAMESPACE} \
  -f kubernetes/values-injected.yaml

echo "=========================================="
echo " Deployment Successful!                   "
echo " Run 'kubectl get pods -n ${NAMESPACE}'   "
echo "=========================================="
