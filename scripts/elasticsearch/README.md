## ELK setup on K8 with PX

This guide demonstrate setup of stateful ELK (Elasticsearch) cluster on K8 1.6.X . 
For K8 setup, please refer official Kubernetes setup guide using kubeadm.

The ELK cluster consists of three major components

1. master nodes
1. client nodes
1. data   nodes

  - Data nodes are those indexed document stored and require stateful volumes 

### Setup PX on K8

change the cluster name from ``mycluster`` to your specified cluster name
change the etcd host path from ``etcd.fake.net`` to your own etcd host
Update drives e.g. /dev/sdb or /dev/xvdb ..etc

     kubectl apply -f "http://install.portworx.com?cluster=mycluster&kvdb=etcd://etcd.fake.net:4001&drives=/dev/sdb,/dev/sdc"

### Create PX volume(s) locally on PX node(s) for the ELK data node(s)
  
      On node1
      /opt/pwx/bin/pxctl v c evol01 --size 100 --repl 1 --nodes LocalNode --io_profile db

      On node2
      /opt/pwx/bin/pxctl v c evol02 --size 100 --repl 1 --nodes LocalNode --io_profile db

      On node3
      /opt/pwx/bin/pxctl v c evol03 --size 100 --repl 1 --nodes LocalNode --io_profile db


you should have three detached volume shown from ``pxctl volume list``

      [root@ip-172-31-42-35 K8-ELK]# /opt/pwx/bin/pxctl v l
      ID                      NAME    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
      807852748764534732      evol01  100 GiB 1       no      no              LOW             1       up - detached
      109602500435512894      evol02  100 GiB 1       no      no              LOW             1       up - detached
      549945525761724000      evol03  100 GiB 1       no      no              LOW             1       up - detached

###Label the K8 nodes 

For ELK data node(s) associate to local PX volume; we have to create node label and reference this node label on the ELK data node deployment spec file.

        $ kubectl get nodes
        NAME               STATUS    AGE       VERSION
        ip-172-31-34-131   Ready     56m       v1.6.6
        ip-172-31-35-102   Ready     56m       v1.6.6
        ip-172-31-38-57    Ready     56m       v1.6.6
        ip-172-31-42-35    Ready     58m       v1.6.6

        $ kubectl label nodes ip-172-31-42-35 disknode=node1
        $ kubectl label nodes ip-172-31-38-57 disknode=node2
        $ kubectl label nodes ip-172-31-35-102 disknode=node3
        $ kubectl label nodes ip-172-31-34-131 disknode=node4


###Create PV and PVC 

Use the pv and pvc spec file from K8-ELK folder

        
        $ kubectl create -f px-data01-pv.yaml
        $ kubectl create -f px-data02-pv.yaml
        $ kubectl create -f px-data03-pv.yaml

        $ kubectl create -f px-pvc-data01.yaml
        $ kubectl create -f px-pvc-data02.yaml
        $ kubectl create -f px-pvc-data03.yaml  

Verify created PV and PVC

        $ kubectl create -f px-pvc-data03.yaml
        persistentvolumeclaim "pvc-evol03" created
        $ kubectl get pv,pvc
        NAME        CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                STORAGECLASS   REASON    AGE
        pv/evol01   100Gi      RWO           Retain          Bound     default/pvc-evol01   evol01sc                 2m
        pv/evol02   100Gi      RWO           Retain          Bound     default/pvc-evol02   evol02sc                 2m
        pv/evol03   100Gi      RWO           Retain          Bound     default/pvc-evol03   evol03sc                 2m

        NAME             STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
        pvc/pvc-evol01   Bound     evol01    100Gi      RWO           evol01sc       1m
        pvc/pvc-evol02   Bound     evol02    100Gi      RWO           evol02sc       1m
        pvc/pvc-evol03   Bound     evol03    100Gi      RWO           evol03sc       1m


### Setup ELK cluster 

Use the spec files provided on the K8-ELK folder

        $ kubectl create -f es-discovery-svc.yaml
        $ kubectl create -f es-svc.yaml
        $ kubectl create -f es-master.yaml

Wait until es-master all pods are completed

        $ kubectl create -f es-client.yaml
        $ kubectl create -f  px-es-data01.yaml
        $ kubectl create -f  px-es-data02.yaml
        $ kubectl create -f  px-es-data03.yaml


Verify all pods,deployment for ELK are successfully created


        $ kubectl get deployment,pods
        NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
        deploy/es-client   2         2         2            2           5m
        deploy/es-data01   1         1         1            1           2m
        deploy/es-data02   1         1         1            1           2m
        deploy/es-data03   1         1         1            1           2m
        deploy/es-master   3         3         3            3           5m

        NAME                            READY     STATUS    RESTARTS   AGE
        po/es-client-3170561982-8mtt8   1/1       Running   0          5m
        po/es-client-3170561982-qsb4w   1/1       Running   0          5m
        po/es-data01-583774158-pjfs3    1/1       Running   0          2m
        po/es-data02-3053483828-g7zfv   1/1       Running   0          2m
        po/es-data03-3620239159-10ncw   1/1       Running   0          2m
        po/es-master-2212299741-bc4nw   1/1       Running   0          5m
        po/es-master-2212299741-mgwvw   1/1       Running   0          5m
        po/es-master-2212299741-nvd0x   1/1       Running   0          5m


Verify PX volumes are attached 

        $ /opt/pwx/bin/pxctl v l
        ID                      NAME    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
        807852748764534732      evol01  100 GiB 1       no      no              LOW             1       up - attached on 172.31.42.35
        109602500435512894      evol02  100 GiB 1       no      no              LOW             1       up - attached on 172.31.38.57
        549945525761724000      evol03  100 GiB 1       no      no              LOW             1       up - attached on 172.31.35.102


Verify Elasticsearch service access

      $ kubectl describe svc elasticsearch
        Name:                   elasticsearch
        Namespace:              default
        Labels:                 component=elasticsearch
                                role=client
        Annotations:            <none>
        Selector:               component=elasticsearch,role=client
        Type:                   LoadBalancer
        IP:                     10.111.107.223
        Port:                   http    9200/TCP
        NodePort:               http    31999/TCP
        Endpoints:              10.36.0.2:9200,10.39.0.2:9200
        Session Affinity:       None
        Events:                 <none>

Access to ELK cluster-ip ``10.111.107.223:9200``

      $ curl http://10.111.107.223:9200
        {
          "name" : "es-client-3170561982-8mtt8",
          "cluster_name" : "myesdb",
          "cluster_uuid" : "btII8ujbRbibaqRgWQUxAA",
          "version" : {
            "number" : "5.4.0",
            "build_hash" : "780f8c4",
            "build_date" : "2017-04-28T17:43:27.229Z",
            "build_snapshot" : false,
            "lucene_version" : "6.5.0"
         },
         "tagline" : "You Know, for Search"
        }
