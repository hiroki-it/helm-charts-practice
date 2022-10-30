.PHONY: start context deploy install-tools

start:
	minikube start --memory 8192 --cpus 8 --nodes 2

context:
	kubectx minikube

deploy: context
	kubectl apply -f ./manifests

install-tools:
	minikube ssh -- "sudo apt-get update -y && sudo apt-get install -y tcptraceroute"


