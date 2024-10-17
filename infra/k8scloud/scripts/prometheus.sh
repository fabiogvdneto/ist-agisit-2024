echo "Access Prometheus at http://localhost:9090"
kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring
