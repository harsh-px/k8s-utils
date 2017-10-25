#!/bin/bash

if [ -z "$ELASTIC_SEARCH_IP" ]; then
    echo "[ERROR] ELASTIC_SEARCH_IP environment variable not set."
    exit 1
fi

if [ -z "$ELASTIC_SEARCH_PORT" ]; then
    echo "[ERROR] ELASTIC_SEARCH_PORT environment variable not set."
    exit 1
fi


kubectl delete -n kube-system sa fluentd || true
kubectl delete -n kube-system clusterrole fluentd || true
kubectl delete -n kube-system clusterrolebinding fluentd || true

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: fluentd
  namespace: kube-system
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  - pods
  - pods/logs
  verbs:
  - get
  - list
  - watch

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: fluentd
roleRef:
  kind: ClusterRole
  name: fluentd
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: kube-system
- kind: ServiceAccount
  name: default
  namespace: kube-system
EOF

kubectl delete -n kube-system configmap fluentd || true
kubectl delete -n kube-system daemonSet fluentd || true

cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd
  namespace: kube-system
data:

  fluent.conf: |
    <source>
      @type systemd
      path /var/log/journal
      filters [{ "_SYSTEMD_UNIT": "docker.service" }]
      pos_file /tmp/dockerservice.pos
      tag journal.dockerd
      read_from_head true
      strip_underscores true
    </source>

    <source>
      @type systemd
      path /var/log/journal
      filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
      pos_file /tmp/k8s-kubelet.pos
      tag journal.kubelet
      read_from_head true
      strip_underscores true
    </source>

    <source>
      type tail
      path /var/log/containers/kube-proxy*.log
      pos_file /tmp/kube-proxy.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%N
      tag kubeproxy.*
      format json
      read_from_head true
      keep_time_key true
    </source>

    <source>
      type tail
      path /var/log/containers/portworx*.log
      pos_file /tmp/px-container.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%N
      tag portworx.*
      format json
      read_from_head true
      keep_time_key true
    </source>

    <filter portworx.**>
      @type rename_key
      rename_rule3 kubernetes.host hostname
    </filter>

    <filter journal.kubelet.**>
      @type rename_key
      rename_rule1 MESSAGE log
      rename_rule2 HOSTNAME hostname
    </filter>

    <filter journal.dockerd.**>
      @type rename_key
      rename_rule1 MESSAGE log
      rename_rule2 HOSTNAME hostname
    </filter>

    <filter **>
      type kubernetes_metadata
    </filter>

    <match journal.dockerd.**>
       type elasticsearch_dynamic
       log_level info
       include_tag_key false
       logstash_prefix journal.dockerd.#indexUUID# ## Prefix for creating an Elastic search index.
       host $ELASTIC_SEARCH_IP
       port $ELASTIC_SEARCH_PORT
       logstash_format true
       buffer_chunk_limit 2M
       buffer_queue_limit 32
       flush_interval 60s  # flushes events ever minute. Can be configured as needed.
       max_retry_wait 30
       disable_retry_limit
       num_threads 8
    </match>

    <match journal.kubelet.**>
       type elasticsearch_dynamic
       log_level info
       include_tag_key false
       logstash_prefix journal.kubelet.#indexUUID# ## Prefix for creating an Elastic search index.
       host $ELASTIC_SEARCH_IP
       port $ELASTIC_SEARCH_PORT
       logstash_format true
       buffer_chunk_limit 2M
       buffer_queue_limit 32
       flush_interval 60s  # flushes events ever minute. Can be configured as needed.
       max_retry_wait 30
       disable_retry_limit
       num_threads 8
    </match>

    <match portworx.**>
       type elasticsearch
       log_level info
       include_tag_key false
       logstash_prefix pxLog.#indexUUID# ## Prefix for creating an Elastic search index.
       host $ELASTIC_SEARCH_IP
       port $ELASTIC_SEARCH_PORT
       logstash_format true
       buffer_chunk_limit 2M
       buffer_queue_limit 32
       flush_interval 60s  # flushes events ever minute. Can be configured as needed.
       max_retry_wait 30
       disable_retry_limit
       num_threads 8
    </match>
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
    version: v1
    kubernetes.io/cluster-service: "true"
spec:
  template:
    metadata:
      labels:
        k8s-app: fluentd-logging
        version: v1
        kubernetes.io/cluster-service: "true"
    spec:
      serviceAccount: fluentd
      serviceAccountName: fluentd
      initContainers:
      - name: fluentd-init
        image: harshpx/fluentd-init:latest
        securityContext:
          privileged: true
        command: ['sh','-c','/usr/bin/init-fluentd.sh']
        volumeMounts:
        - name: config
          mountPath: /tmp
      containers:
        - name: fluentd
          image: hrishi/fluentd:v1
          securityContext:
            privileged: true
          volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: runlog
              mountPath: /run/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
            - name: posloc
              mountPath: /tmp
            - name: config
              mountPath: /fluentd/etc/fluent.conf
              subPath: fluent.conf
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
        - name: runlog
          hostPath:
            path: /run/log
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
        - name: config
          configMap:
            name: fluentd
        - name: posloc
          hostPath:
            path: /tmp
EOF