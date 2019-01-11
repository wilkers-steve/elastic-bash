#!/bin/bash

OPTIND=1

labels=""
uri=""
num=""
field=""

while getopts "l:u:f:n:" opt; do
  case "$opt" in
    l)  labels=$OPTARG;;
    u)  uri=$OPTARG;;
    n)  num=$OPTARG;;
    f)  field=$OPTARG;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "labels='$labels', uri='$uri', num='$num', field='$field',Leftovers: $@"

query='{"query":{"bool":{"filter": ['
filters=''
IFS=' '
IFS=',' read -ra LABELS <<< "$labels"
num_labels=${#LABELS[@]}
label_index=0
for label in "${LABELS[@]}"; do
  IFS=':' read -ra VALUES <<< "$label"
  if [[ "$label_index" < $(expr "$num_labels" - 1) ]]; then
    label_filter='{"term":{"'"${VALUES[0]}"'":"'"${VALUES[1]}"'"}},'
    filters="$filters$label_filter"
  else
    label_filter='{"term":{"'"${VALUES[0]}"'":"'"${VALUES[1]}"'"}}'
    filters="$filters$label_filter]}}}"
  fi
  label_index=$(expr $label_index + 1)
done

query="$query$filters"

if [ "$field" == "log" ]; then
  curl -gv "${uri}/_search?size=${num}" -H"Content-Type: application/json" -d"${query}" \
  | python3 -c "import sys, json; results=json.load(sys.stdin);hits=results['hits']['hits'];logs=[(result['_source']['kubernetes']['host']+' | '+result['_source']['kubernetes']['pod_name']+' | '+result['_source']['log']) for result in hits];print(*logs, sep='\n')"
elif [ "$field" == "message" ]; then
  curl -gv "${uri}/_search?size=${num}" -H"Content-Type: application/json" -d"${query}" \
  | python3 -c "import sys, json; results=json.load(sys.stdin);hits=results['hits']['hits'];logs=[result['_source']['message'] for result in hits];print(*logs, sep='\n')"
elif [ "$field" == "MESSAGE" ]; then
  curl -gv "${uri}/_search?size=${num}" -H"Content-Type: application/json" -d"${query}" \
  | python3 -c "import sys, json; results=json.load(sys.stdin);hits=results['hits']['hits'];logs=[result['_source']['MESSAGE'] for result in hits];print(*logs, sep='\n')"
fi
