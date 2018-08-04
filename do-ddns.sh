if [[ -z ${1} ]]
  then
  echo -e "Usage: $(basename ${0}) <fqdn>"
  exit 1
fi

DOMAIN="example.org"
HOST="${1}"
HOSTNAME="${HOST/\.${DOMAIN}/}"
DOCTL="/usr/local/bin/doctl"
TELEGRAM_SEND="/usr/local/bin/telegram-send --stdin" 

CURRENT_IP=$(curl -s ifconfig.co)
if [[ -z ${CURRENT_IP} || ${#CURRENT_IP} -gt 15 ]]
  then
  # Couldn't get current IP from ifconfig.co, so stop everything
  echo -e "Failed to check for current IP!" | ${TELEGRAM_SEND}
  exit 2
fi

declare -A RECORD

get_record_id() {
  RECORD["ID"]=$(${DOCTL} compute domain records list ${DOMAIN} --no-header --format ID,Name | grep " ${1}"  | awk '{ print $1 }')
}

get_record() {
  RECORD["Name"]="${1}"
  get_record_id ${RECORD["Name"]}
  declare -a RAW_RECORD
  RAW_RECORD=($(${DOCTL} compute domain records list ${DOMAIN} --no-header --format ID,Data,TTL | grep ^${RECORD["ID"]}))
  RECORD["Data"]="${RAW_RECORD[1]}"
  RECORD["TTL"]="${RAW_RECORD[2]}"
}

update_record() {
  get_record "${1}"
  ${DOCTL} compute domain records update ${DOMAIN} --record-id=${RECORD["ID"]} --record-name="${RECORD["Name"]}" --record-ttl="${RECORD["TTL"]}" --record-data="${2}" > /dev/null 2>&1 
}

check_ip() {
  DNS_IP=$(dig +short a ${HOST} @ns1.digitalocean.com)
  if [[ -z ${DNS_IP} ]]
    then
      # Means querying DO failed, so stop everything
      echo -e "Failed to check IP registered on DigitalOcean!" | ${TELEGRAM_SEND}
      exit 3
  fi

  if [[ ${DNS_IP} = ${CURRENT_IP} ]]
    then
      return 1
    else
      return 0
  fi
}

send_notification() {
  {
    date
    echo -e "\nIP for ${HOST} was updated!"
    echo -e "Previous IP: ${RECORD["Data"]}"
    echo -e "Current IP: ${CURRENT_IP}"
  } | ${TELEGRAM_SEND}
}

post_exec() {
  # If you want to do any post execution routine
  return 0
}

if ( check_ip )
  then
    update_record ${HOSTNAME} ${CURRENT_IP}
    send_notification
    post_exec
fi

exit 0
