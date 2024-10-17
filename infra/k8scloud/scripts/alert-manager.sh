echo "Access Alert Manager at http://localhost:9093"
kubectl port-forward svc/prom-operator-kube-prometh-alertmanager 9093:9093 -n monitoring
