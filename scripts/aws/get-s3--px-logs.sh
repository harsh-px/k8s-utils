#!/bin/bash -ex

DEFAULT_DUMP_LOCATION=/tmp/px-s3-logs-`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''`

function usage() {
    echo "USAGE: ${0} -b bucket [-p <bucket-prefix>]"
    exit 1
}

while getopts p:b: option
do
    case "${option}"
    in
    p) PREFIX=${OPTARG};;
    b) BUCKET=${OPTARG};;
    esac
done

if [ -z "$BUCKET" ]
then
    echo "Error: S3 bucket not given"
    usage
fi

if [ -z "$" ]
then
    echo "Defaulting to empty bucket prefix"
fi

mkdir -p ${DEFAULT_DUMP_LOCATION}

echo "Fetching S3 objects from bucket:${BUCKET} with prefix:${PREFIX}"

for obj in `aws s3api list-objects --bucket "${BUCKET}" --prefix "${PREFIX}"  --query "sort_by(Contents,&LastModified)" --output json | jq -c  '.[] | .Key'`; do
		echo "doing get on $obj.."
    aws s3api get-object --bucket ${BUCKET} --key "${obj//\"}" ${DEFAULT_DUMP_LOCATION}/$(basename "${obj//\"}")

    #Extract
    gzip -cd ${DEFAULT_DUMP_LOCATION}/$(basename "${obj//\"}") >> ${DEFAULT_DUMP_LOCATION}/master.json
done

echo "All logs merged at: ${DEFAULT_DUMP_LOCATION}/master.json"

# TODO Post to ES
# cat ${DEFAULT_DUMP_LOCATION}/master.json | jq -c '. | {"index": {"_index": "logs", "_type": "log",}}, .' | curl -XPOST localhost:9200/_bulk --data-binary @-
