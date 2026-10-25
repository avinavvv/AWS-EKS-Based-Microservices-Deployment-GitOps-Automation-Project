FROM --platform=$TARGETPLATFORM python:3.14.2-alpine@sha256:7af51ebeb83610fb69d633d5c61a2efb87efa4caf66b59862d624bb6ef788345 AS base

FROM base AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk update \
    && apk add --no-cache g++ linux-headers \
    && rm -rf /var/cache/apk/*

# Install packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk update \
    && apk add --no-cache libstdc++ \
    && rm -rf /var/cache/apk/*

WORKDIR /recommendationservice

# Copy installed Python packages and scripts
COPY --from=builder /usr/local/lib/python3.14/ /usr/local/lib/python3.14/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Add application files
COPY . .

ENV PORT="8080"
EXPOSE 8080

ENTRYPOINT ["python", "recommendation_server.py"]
