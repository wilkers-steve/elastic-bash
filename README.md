# elastic-bash
A quick and dirty bash script for querying Elasticsearch

## Usage
```
./es_query.sh -l <labels> -u <uri> -n <number> -f <field>
```

## Flags
* ```-l (labels):``` Comma delimited list of <key>:<value> formatted labels to query against
* ```-u (uri):``` Elasticsearch URI to query (with auth credentials, if enabled)
* ```-n (number):``` Number of results to return from query
* ```-f (field):``` The field in logged event to return (log, message, or MESSAGE)

### labels
A comma delimited list of key:value formatted labels to query Elasticsearch for.  These labels are
typically applied by a log gathering daemon (Fluentbit, Fluentd, Filebeat, etc). They must be defined
as indexed fields in your Elasticsearch index to be able to query against them.

### uri
The endpoint for the Elasticsearch instance to query.  If basic auth is enabled, the endpoint must
include the user and password.

### number
The number of results to return.  By default, Elasticsearch will only return the top ten matches
for a query.

### field
The field that includes the log message desired.  The default logstash index will place the content
of the message under the *log* field.  The systemd input plugin for Fluentbit places the content of
the message under the *MESSAGE* field.  Most other messages, including the OpenStack oslo fluentd
formatter, are placed under the *message* field.


## Examples
### Query for all Elasticsearch data node logs, return 100 events
```
./es_query.sh -l kubernetes.labels.application.keyword:elasticsearch, \
                 kubernetes.labels.component.keyword:data \
              -u http://user:password@elasticsearch:9200 \
              -n 100
              -f log
```

### Query for all docker logs gathered by the Fluentbit journald plugin, return 100 events
```
./es_query.sh -l SYSTEMD_UNIT:docker.service \
              -u http://user:password@elasticsearch:9200 \
              -n 100
              -f MESSAGE
```
