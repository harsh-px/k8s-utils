FROM lachlanevenson/k8s-kubectl:v1.9.10

RUN apk update && apk upgrade && apk add bash jq

WORKDIR /

ADD k8s_add_service_account_kubeconfig.sh /k8s_add_service_account_kubeconfig.sh

ENTRYPOINT ["bash", "/k8s_add_service_account_kubeconfig.sh"]
CMD []
