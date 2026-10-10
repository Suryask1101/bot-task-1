#!/usr/bin/env bash
set -Eeuo pipefail

# Resolve the repository path so the script works from any directory.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

CLUSTER_NAME="demo"
NAMESPACE="demo"
RELEASE_NAME="demo"
IMAGE_NAME="demo-service:1.0.0"
INGRESS_MANIFEST="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

for cmd in docker kind kubectl helm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Required command '$cmd' is not installed." >&2
    exit 1
  fi
done

docker info >/dev/null

# Create the cluster only when it does not already exist.
if ! kind get clusters | grep -Fxq "$CLUSTER_NAME"; then
  echo "Creating kind cluster: $CLUSTER_NAME"

  KIND_CONFIG="$(mktemp)"
  trap 'rm -f "${KIND_CONFIG:-}"' EXIT

  cat > "$KIND_CONFIG" <<'KIND_EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
KIND_EOF

  kind create cluster --name "$CLUSTER_NAME" --config "$KIND_CONFIG"
  rm -f "$KIND_CONFIG"
  trap - EXIT
else
  echo "Reusing existing kind cluster: $CLUSTER_NAME"
fi

kubectl cluster-info --context "kind-${CLUSTER_NAME}"

# Install or update ingress-nginx using the official kind manifest.
kubectl apply -f "$INGRESS_MANIFEST"

kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# Build the application image and make it available to kind.
docker build -t "$IMAGE_NAME" "$ROOT_DIR/service"
kind load docker-image "$IMAGE_NAME" --name "$CLUSTER_NAME"

# Create the application namespace if necessary.
kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Install the chart on the first run; upgrade it on subsequent runs.
helm upgrade --install "$RELEASE_NAME" "$ROOT_DIR/chart" \
  --namespace "$NAMESPACE" \
  --wait \
  --timeout 180s

# Wait until the application rollout is available.
kubectl rollout status deployment/"$RELEASE_NAME" \
  --namespace "$NAMESPACE" \
  --timeout=180s

echo
echo "Setup completed successfully."
echo "Pods:"
kubectl get pods --namespace "$NAMESPACE"
echo
echo "Service and Ingress:"
kubectl get svc,ingress --namespace "$NAMESPACE"
