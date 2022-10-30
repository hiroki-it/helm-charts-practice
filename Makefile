.PHONY: start context deploy

start:
	minikube start --memory 8192 --cpus 8 --nodes 2

context:
	kubectx minikube

deploy: context
	kubectl apply -f ./manifests
