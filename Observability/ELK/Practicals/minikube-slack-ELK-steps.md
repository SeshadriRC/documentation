## High level steps



Kibana
-------
Stack management --> Rules and connectors --> Create rule --> Rule type Elasticsearch query

<img width="1917" height="852" alt="image" src="https://github.com/user-attachments/assets/d7e39db3-8379-43a6-a571-643346aaafc1" />




```
IF

kubernetes.pod.name = any pod
AND
log.level = ERROR

AND

ERROR count > 10
within 5 minutes

THEN

Send Slack alert
```

Slack
-----
Create a private slack channel 

Add apps --> manage --> incoming webhook --> Add to slack --> choose a channel --> Add incoming webhook integratios --> copy the webhook URL


Kibana
------
Stack management --> Connectors --> Create your first connector --> Select a slack as a connector

```
Connector name: Slack Alert connector
Connector settings: webhook URL
Save and test 
create an action --> run the test --> check the slack
```

Alerts --> manage rules --> click slack alert --> Actions --> edit rule --> connector type --> slack --> save it

---

## Full practicals

```bash
Update the Package List.
sudo apt update

Installs essential tools like curl, wget and apt-transport-https.
sudo apt install curl wget apt-transport-https -y

Installs Docker, a container runtime that will be used as the VM driver for Minikube.
sudo apt install docker.io -y

sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock

egrep -q 'vmx|svm' /proc/cpuinfo && echo yes || echo no
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon

sudo adduser $USER libvirt
sudo adduser $USER libvirt-qemu

newgrp libvirt
newgrp libvirt-qemu

# Install Minikube and kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

minikube version

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/

# Start the Minikube
minikube start --vm-driver docker --cpus=4 --memory=8192
minikube status

# Install the Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
helm repo add elastic https://helm.elastic.co
helm repo update

# Deploy the ELK Stack and Filebeat
elasticsearch-values.yaml
helm install elasticsearch elastic/elasticsearch -f elasticsearch-values.yaml

nano filebeat-values.yaml
helm install filebeat elastic/filebeat -f filebeat-values.yaml

nano logstash-values.yaml
helm install logstash elastic/logstash -f logstash-values.yaml

nano kibana-values.yaml
helm install kibana elastic/kibana -f kibana-values.yaml

# Access the ELK Stack
kubectl get services
kubectl port-forward --address 0.0.0.0 svc/kibana-kibana 5601:5601
kubectl get secret elasticsearch-master-credentials -o jsonpath="{.data.username}" | base64 --decode ; echo
kubectl get secret elasticsearch-master-credentials -o jsonpath="{.data.password}" | base64 --decode ; echo
```


**elasticsearch-values**

```yaml
resources:
  requests:
    cpu: "200m"
    memory: "200Mi"
  limits:
    cpu: "1000m"
    memory: "2Gi"

antiAffinity: "soft"
```

**filebeat-values**

```yaml
filebeatConfig:
  filebeat.yml: |-
    filebeat.inputs:
      - type: container
        paths:
          - /var/log/containers/*.log
        processors:
          - add_kubernetes_metadata:
              host: ${NODE_NAME}
              matchers:
                - logs_path:
                    logs_path: "/var/log/containers/"

    output.logstash:
      hosts: ["logstash-logstash:5044"]
```

**logstash-values**

```yaml
extraEnvs:
  - name: "ELASTICSEARCH_USERNAME"
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: username
  - name: "ELASTICSEARCH_PASSWORD"
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: password

logstashConfig:
  logstash.yml: |
    http.host: 0.0.0.0
    xpack.monitoring.enabled: false

logstashPipeline:
  logstash.conf: |
    input {
      beats {
        port => 5044
      }
    }

    output {
      elasticsearch {
        hosts => ["https://elasticsearch-master:9200"]
        cacert => "/usr/share/logstash/config/elasticsearch-master-certs/ca.crt"
        user => '${ELASTICSEARCH_USERNAME}'
        password => '${ELASTICSEARCH_PASSWORD}'
      }
    }

secretMounts:
  - name: "elasticsearch-master-certs"
    secretName: "elasticsearch-master-certs"
    path: "/usr/share/logstash/config/elasticsearch-master-certs"

service:
  type: ClusterIP
  ports:
    - name: beats
      port: 5044
      protocol: TCP
      targetPort: 5044
    - name: http
      port: 8080
      protocol: TCP
      targetPort: 8080

resources:
  requests:
    cpu: "200m"
    memory: "200Mi"
  limits:
    cpu: "1000m"
    memory: "1536Mi" 
```

**kibana-values**

```bash
openssl rand -base64 32
JMSe----
```

```yaml
kibanaConfig:
  kibana.yml: |
    xpack.encryptedSavedObjects.encryptionKey: "JMSe"

service:
  type: NodePort
  port: 5601

resources:
  requests:
    cpu: "200m"
    memory: "200Mi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
```

**metricbeat-rbac.yml**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metricbeat
  namespace: default

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: metricbeat
rules:
  - apiGroups: [""]
    resources:
      - nodes
      - nodes/stats
      - pods
      - namespaces
      - events
      - services
      - endpoints
      - persistentvolumes
      - persistentvolumeclaims
      - resourcequotas
    verbs: ["get", "list", "watch"]

  - apiGroups: ["apps"]
    resources:
      - deployments
      - replicasets
      - statefulsets
      - daemonsets
    verbs: ["get", "list", "watch"]

  - apiGroups: ["batch"]
    resources:
      - jobs
      - cronjobs
    verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: metricbeat
subjects:
  - kind: ServiceAccount
    name: metricbeat
    namespace: default
roleRef:
  kind: ClusterRole
  name: metricbeat
  apiGroup: rbac.authorization.k8s.io
```

**metricbeat-values.yml**

```yaml
daemonset:
  enabled: true

deployment:
  enabled: false

serviceAccount: metricbeat

extraEnvs:
  - name: ELASTICSEARCH_USERNAME
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: username

  - name: ELASTICSEARCH_PASSWORD
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: password

secretMounts:
  - name: elasticsearch-master-certs
    secretName: elasticsearch-master-certs
    path: /usr/share/metricbeat/certs

metricbeatConfig:
  metricbeat.yml: |
    metricbeat.modules:
      - module: kubernetes
        metricsets:
          - node
          - pod
          - container
          - system
        period: 10s
        host: ${NODE_NAME}
        hosts:
          - https://${NODE_NAME}:10250
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        ssl.verification_mode: none

    processors:
      - add_kubernetes_metadata:
          host: ${NODE_NAME}

    output.elasticsearch:
      hosts: ["https://elasticsearch-master:9200"]
      username: "${ELASTICSEARCH_USERNAME}"
      password: "${ELASTICSEARCH_PASSWORD}"
      ssl.certificate_authorities:
        - /usr/share/metricbeat/certs/ca.crt

resources:
  requests:
    cpu: "100m"
    memory: "100Mi"
  limits:
    cpu: "500m"
    memory: "500Mi"
```

```bash
helm search repo elastic/metricbeat --versions | head


kubectl label serviceaccount metricbeat \
  app.kubernetes.io/managed-by=Helm \
  -n default
  
kubectl annotate serviceaccount metricbeat \
  meta.helm.sh/release-name=metricbeat \
  meta.helm.sh/release-namespace=default \
  -n default
  
helm install metricbeat elastic/metricbeat \
  --version 8.5.1 \
  -n default \
  -f metricbeat-values.yml
```

<img width="1917" height="470" alt="image" src="https://github.com/user-attachments/assets/c3842022-2128-4e3b-8ed0-458c99ef12ab" />

<img width="1537" height="455" alt="image" src="https://github.com/user-attachments/assets/b1c8095c-07e6-48e3-a8f4-0c74aeb4781d" />

<img width="1897" height="832" alt="image" src="https://github.com/user-attachments/assets/11528a5d-f860-4962-9178-415eb9e42694" />

<img width="967" height="606" alt="image" src="https://github.com/user-attachments/assets/0be92584-9e56-4ca5-b518-9ca536b706ac" />

<img width="1885" height="828" alt="image" src="https://github.com/user-attachments/assets/b8ff9412-6633-480c-928a-f5ca36386ad3" />

<img width="958" height="505" alt="image" src="https://github.com/user-attachments/assets/9b393ae7-4248-4062-9c8d-3bef25de2074" />

<img width="1897" height="702" alt="image" src="https://github.com/user-attachments/assets/02086616-cd08-4048-a4f0-83ff85292fde" />

Stack management --> Rules and connectors --> Create rule --> Rule type Elasticsearch query

<img width="1917" height="852" alt="image" src="https://github.com/user-attachments/assets/d7e39db3-8379-43a6-a571-643346aaafc1" />

<img width="1900" height="597" alt="image" src="https://github.com/user-attachments/assets/e9d1937d-343a-4e4c-bbc4-833da740cb8b" />

<img width="1912" height="425" alt="image" src="https://github.com/user-attachments/assets/396a06d6-4a43-4778-a469-34493ab45c79" />
