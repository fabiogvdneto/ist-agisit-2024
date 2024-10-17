echo "Access Grafana at http://localhost:3000"
kubectl port-forward svc/prom-operator-grafana 3000:80 -n monitoring
