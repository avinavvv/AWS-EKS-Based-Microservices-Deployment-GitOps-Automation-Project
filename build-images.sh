#!/bin/bash
set -Eeuo pipefail

DOCKERHUB_USER="${DOCKERHUB_USER:-avinavv}"
TAG="${TAG:-v1}"
PUSH="${PUSH:-false}"

if [[ "$PUSH" == "true" ]]; then
  PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
else
  if [[ -n "${PLATFORMS:-}" && "$PLATFORMS" == *,* ]]; then
    echo "Multi-platform builds require PUSH=true. Authenticate to Docker Hub first." >&2
    exit 1
  fi

  if [[ -z "${PLATFORMS:-}" ]]; then
    case "$(docker info --format '{{.Architecture}}')" in
      aarch64|arm64) PLATFORMS=linux/arm64 ;;
      x86_64|amd64) PLATFORMS=linux/amd64 ;;
      *)
        echo "Unsupported local Docker architecture; set PLATFORMS explicitly." >&2
        exit 1
        ;;
    esac
  fi
fi

docker buildx inspect --bootstrap >/dev/null

services=(
  adservice
  cartservice
  checkoutservice
  currencyservice
  emailservice
  frontend
  loadgenerator
  paymentservice
  productcatalogservice
  recommendationservice
  shippingservice
  shoppingassistantservice
)

for service in "${services[@]}"; do
  echo "========== Building $service =========="

  if [ "$service" = "cartservice" ]; then
    dockerfile=src/cartservice/src/Dockerfile
    context=src/cartservice/src
  else
    dockerfile="src/$service/Dockerfile"
    context="src/$service"
  fi

  output=--load
  if [[ "$PUSH" == "true" ]]; then
    output=--push
  fi

  docker buildx build \
    --platform "$PLATFORMS" \
    "$output" \
    -t "$DOCKERHUB_USER/$service:$TAG" \
    -f "$dockerfile" \
    "$context"

  echo "SUCCESS: $service"
done

if [[ "$PUSH" == "true" ]]; then
  echo "All multi-platform images were pushed successfully."
else
  echo "All images were built successfully for $PLATFORMS."
fi
