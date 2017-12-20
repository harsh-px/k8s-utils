#!/bin/bash

if [ -z "$AWS_KEY_ID" ]; then
    echo "[ERROR] AWS_KEY_ID environment variable not set."
    exit 1
fi

if [ -z "$AWS_SECRET_KEY_ID" ]; then
    echo "[ERROR] AWS_SECRET_KEY_ID environment variable not set."
    exit 1
fi

if [ -z "$S3_BUCKET" ]; then
    echo "[ERROR] S3_BUCKET environment variable not set."
    exit 1
fi

if [ -z "$S3_REGION" ]; then
    echo "[ERROR] S3_REGION environment variable not set."
    exit 1
fi


kubectl delete -n kube-system sa fluentd || true
kubectl delete -n kube-system clusterrole fluentd || true
kubectl delete -n kube-system clusterrolebinding fluentd || true

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: fluentd-px-secrets
  namespace: kube-system
type: Opaque
data:
  AWS_KEY_ID: $AWS_KEY_ID
  AWS_SECRET_KEY_ID: $AWS_SECRET_KEY_ID
  S3_BUCKET: $S3_BUCKET
  S3_REGION: $S3_REGION
EOF

cat <<EOF | kubectl apply -f -
---
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
     pos_file /tmp/docker-service.pos
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
      @type systemd
      path /var/log/journal
      filters [{ "_SYSTEMD_UNIT": "portworx.service" }]
      pos_file /tmp/portworxservice.pos
      tag journal.portworx
      read_from_head true
      strip_underscores true
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

    <filter journal.portworx.**>
      @type rename_key
      rename_rule1 MESSAGE log
      rename_rule2 HOSTNAME hostname
    </filter>

    <filter **>
      type kubernetes_metadata
    </filter>
    
    <match journal.portworx.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/journal-portworx/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 3m
       utc
       buffer_chunk_limit 256m
    </match>

    <match journal.dockerd.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/journal-dockerd/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 3m
       utc
       buffer_chunk_limit 256m
    </match>

    <match journal.kubelet.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/journal-kubelet/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 3m
       utc
       buffer_chunk_limit 256m
    </match>

    <match portworx.**>
       @type s3
       aws_key_id #AWS_KEY_ID#
       aws_sec_key #AWS_SECRET_KEY_ID#
       s3_bucket #S3_BUCKET#
       s3_region #S3_REGION#
       path logs/
       buffer_path /var/log/px-container/s3
       s3_object_key_format #indexUUID#_%{path}%{time_slice}_%{index}.%{file_extension}          
       time_slice_format %Y%m%d%H
       time_slice_wait 1m
       utc
       buffer_chunk_limit 256m
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
        image: hrishi/fluentd-initutils-s3:v1
        imagePullPolicy: Always
        securityContext:
          privileged: true
        command: ['/bin/sh']
        args: ['-c','/usr/bin/init-fluentd.sh portworx-service']
        env:
        - name: "AWS_KEY_ID"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: AWS_KEY_ID
        - name: "AWS_SECRET_KEY_ID"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: AWS_SECRET_KEY_ID
        - name: "S3_BUCKET"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: S3_BUCKET
        - name: "S3_REGION"
          valueFrom:
            secretKeyRef:
              name: fluentd-px-secrets
              key: S3_REGION
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
            path: /mnt
EOF
