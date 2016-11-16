# Orders Service Example

This is a sample service adapted from the ticket monster app.

## Build and run locally

```
mvn clean install
```


Call it here:

```
curl -v -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d '{"ticketRequests":[{"ticketPriceGuideId":1,"quantity":1}],"email":"foo@bar.com","performance":1,"performanceName":"Rock concert of the decade at Roy Thomson Hall"}'  http://localhost:8080/orders/bookings
```


```
mvn wildfly-swarm:run
```


## Running with a MySQL backend:

```
mvn clean package -Pmysql
```


## Bootstrap the databases

We need to refer to the mysql database template from [https://github.com/christian-posta/ticket-monster-infra](https://github.com/christian-posta/ticket-monster-infra). We can install the template with:

```
oc create -f mysql-openshift-template.yml
```

Now let's create the mysql database for the admin microservice:

```
oc process ticket-monster-mysql -v DATABASE_SERVICE_NAME=mysqlorders | oc create -f -
oc deploy mysqlorders --latest
```


## Liquibase commands

As root, we can reset the database:

```
mysql> drop database ticketmonster; create database ticketmonster;
```

```
mvn -Pdb-migration-mysql liquibase:update -Dliquibase.url=http://localhost:3306
mvn -Pdb-migration-mysql liquibase:updateSQL -Dliquibase.url=http://localhost:3306
mvn -Pdb-migration-mysql liquibase:status -Dliquibase.url=http://localhost:3306
mvn -Pdb-migration-mysql liquibase:tag -Dliquibase.tag=v2.0 -Dliquibase.url=http://localhost:3306
```

Automatically discover diffs between the existing schema and what Hibernate sees currently

```
mvn -Pdb-migration-mysql liquibase:diff -Dliquibase.referenceUrl=hibernate:ejb3:primary
```

Generate the changeLog to a file:
```
mvn -Pmysql,db-migration-mysql liquibase:diff -Dliquibase.referenceUrl=hibernate:ejb3:primary -Dliquibase.diffChangeLogFile=target/changes.yml
```

From here you can evaluate what changes should go into the next `update`

After an update, it's recommended to tag if things went successful, or rollback if not.

Also, you can see what tags exist in the DB:

```
select ID, DATEEXECUTED,TAG from DATABASECHANGELOG WHERE TAG IS NOT NULL ORDER BY DATEEXECUTED;
```



TODO: eliminate sending back data model elements directly; we should make more clearly the "view" model and the "write" model .. this will involve cleaning up the DTO objects if they're not needed in the write model