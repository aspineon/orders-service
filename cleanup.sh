#!/usr/bin/env bash

# delete app stuff
oc delete is/orders-service-mysql
oc delete bc/orders-service-mysql-s2i

# delete database stuff
oc delete svc/mysqlorders

