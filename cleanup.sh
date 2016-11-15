#!/usr/bin/env bash

# delete app stuff
oc delete is/orders-service-mysql
oc delete bc/orders-service-mysql-s2i
oc delete dc/orders-service-mysql
oc delete svc/orders-service-mysql

# delete database stuff
oc delete svc/mysqlorders
oc delete deployment/mysqlorders