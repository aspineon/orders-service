#!/usr/bin/env bash

# delete app stuff
oc delete is/orders-service-mysql --namespace=default-testing
oc delete is/orders-service-mysql --namespace=default-staging
oc delete is/orders-service-mysql --namespace=default-production

oc delete bc/orders-service-mysql-s2i --namespace-default

oc delete dc/orders-service-mysql --namespace=default-testing
oc delete dc/orders-service-mysql --namespace=default-staging
oc delete dc/orders-service-mysql --namespace=default-production

oc delete svc/orders-service-mysql --namespace=default-testing
oc delete svc/orders-service-mysql --namespace=default-staging
oc delete svc/orders-service-mysql --namespace=default-production

docker rmi $(docker images | grep default | awk '{print $1}')