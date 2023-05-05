#!/bin/bash

CR_TO_COPY=347622
REPO_DIR=/repos/Aprimo/change-requests

usage ()
{
   # Display Help
   echo ""
   echo "Syntax: new-k8s-change-request.sh [-hct]"
   echo "options:"
   echo "-c     change request (ticket number)"
   echo "-t     tenant"
   echo "-n     nginx PR number"
   echo "-h     Print this Help."
   echo
   exit 1
}

# Get the options
while getopts ":h:c:t:n:" option; do
   case $option in
      h) # display Help
         usage
         ;;
      c) #set CR_TO_COPY
        CR=${OPTARG}
        ;;
      t)
        TENANT=${OPTARG}
        ;; 
      n) 
        NGINX_PR=${OPTARG}
        ;;
   esac
done
shift $((OPTIND-1))

if [ -z "${CR}" ]
then
  usage
fi

if [ -z "${TENANT}" ]
then
  usage
fi

if [ -z "${NGINX_PR}" ]
then
  usage
fi

# cd /repos/Aprimo/change-requests/
echo "*** changing directory to $REPO_DIR"
cd $REPO_DIR

# create a git branch
# checkout main and git pull first 
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ $CURRENT_BRANCH != 'main' ]]
then 
  echo "*** checkout out main branch"
  git checkout main
fi

git pull

# create a new branch
echo "*** creating branch wip/${CR}-migrate-${TENANT}"
git checkout -b wip/${CR}-migrate-${TENANT}

# copy a similar change request
cp ${REPO_DIR}/changes/${CR_TO_COPY}.md ${REPO_DIR}/changes/${CR}.md
echo "*** copying change request #$CR_TO_COPY"
echo "*** creating CR for tenant: $TENANT"

# replace the ticket number 
sed -i "s/$CR_TO_COPY/$CR/g" ${REPO_DIR}/changes/${CR}.md

# replace the client name/URL 
sed -i "s/mdlzna/$TENANT/g" ${REPO_DIR}/changes/${CR}.md

# replace the Nginx PR
sed -i "s/42147/$NGINX_PR/g" ${REPO_DIR}/changes/${CR}.md

git add . 
git commit -m "Redirecting PM API Traffic for $TENANT to Kubernetes"
git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)
