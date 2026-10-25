#!/bin/bash
set -e

DOCKERHUB_USER="avinavv"
PLATFORM="linux/amd64"

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
    docker buildx build \
      --platform "$PLATFORM" \
      --load \
      -t "$DOCKERHUB_USER/$service:v1" \
      -f src/cartservice/src/Dockerfile \
      src/cartservice/src
  else
    docker buildx build \
      --platform "$PLATFORM" \
      --load \
      -t "$DOCKERHUB_USER/$service:v1" \
      -f "src/$service/Dockerfile" \
      "src/$service"
  fi

  echo "SUCCESS: $service"
done

echo "All images built successfully."

