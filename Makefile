.PHONY: start context apply-kubernetes apply-istio-operator apply-istio service-discovery-by-kube-proxy install-tools

start:
	minikube start --memory 8192 --cpus 8 --nodes 2

context:
	kubectx minikube
	kubectx

apply-kubernetes: context
	minikube kubectl apply -f ./infra/kubernetes

apply-istio-operator: context
	istioctl x precheck
	istioctl install -f ./infra/istio/istio-operator.yaml --dry-run
	istioctl install -f ./infra/istio/istio-operator.yaml
	istioctl verify-install -f ./infra/istio/istio-operator.yaml
	istioctl tag set stable --revision 1-13-9

apply-istio: context
	minikube kubectl apply -f ./infra/istio

install-tools:
	minikube ssh -- "sudo apt-get update -y && sudo apt-get install -y tcptraceroute"

service-discovery-by-kube-proxy: context
	minikube ssh -- sudo iptables -nL KUBE-SERVICES -t nat --line-number
