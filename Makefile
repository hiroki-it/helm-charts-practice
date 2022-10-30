.PHONY: start context deploy install-tools

start:
	minikube start --memory 8192 --cpus 8 --nodes 2

context:
	kubectx minikube
	kubectx

apply-kubernetes: context
	minikube kubectl apply -f ./kubernetes

apply-istio: context
	minikube kubectl apply -f ./istio

install-tools:
	minikube ssh -- "sudo apt-get update -y && sudo apt-get install -y tcptraceroute"

service-discovery-by-kube-proxy:
	minikube ssh -- sudo iptables -nL KUBE-SERVICES -t nat --line-number
