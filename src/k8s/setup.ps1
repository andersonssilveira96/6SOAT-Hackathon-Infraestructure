# Metrics para obter informações e fazer o HPA da API.
kubectl apply -f ./src/k8s/metrics-server.yaml

# RabbitMQ
kubectl apply -f ./src/k8s/rabbitmq-deployment.yaml
kubectl apply -f ./src/k8s/rabbitmq-service.yaml

# API Cadastro
kubectl apply -f ./src/k8s/api-cadastro-secret.yaml
kubectl apply -f ./src/k8s/api-cadastro-deployment.yaml
kubectl apply -f ./src/k8s/api-cadastro-svc.yaml
kubectl apply -f ./src/k8s/api-cadastro-hpa.yaml

# API Processamento
kubectl apply -f ./src/k8s/api-processamento-secret.yaml
kubectl apply -f ./src/k8s/api-processamento-deployment.yaml
kubectl apply -f ./src/k8s/api-processamento-svc.yaml
kubectl apply -f ./src/k8s/api-processamento-hpa.yaml
