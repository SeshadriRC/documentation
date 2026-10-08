## High level steps

Kibana
-------
Observability --> Alerts --> Manage rules --> create rule --> metric threshold 

name: slack alert
select conditions

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
