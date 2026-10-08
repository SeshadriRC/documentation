```

helm repo add elastic https://helm.elastic.co

helm repo update

helm search repo elastic/metricbeat --versions | head

helm install metricbeat elastic/metricbeat \
  --version 8.5.1 \
  -n default \
  -f metricbeat-values.yml
```
