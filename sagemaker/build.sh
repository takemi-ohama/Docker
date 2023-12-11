name=`basename ${PWD}`
tag=`date +%Y%m%d`

registry=hammer
region=us-west-2
profile=nyle
private_ecr=644301431885.dkr.ecr.${region}.amazonaws.com
quote_name=\"${name}\"

OID=1001
latest=latest${OID}

set -xe

if [ -n "${OID}"i ]; then
  docker build --no-cache --build-arg O_UID=${OID} --build-arg O_GID=${OID} -t ${registry}/${name}:${tag} .
else
  docker build --no-cache -t ${registry}/${name}:${tag} .
fi

docker tag ${registry}/${name}:${tag} ${registry}/${name}:${latest}

function pushDockerHub(){
    docker login
    docker push ${registry}/${name}:${tag}
    docker push ${registry}/${name}:${latest}
    echo "pushed: ${registry}/${name}:${tag}"
}

function pushPrivateECR(){
  aws ecr get-login-password --profile ${profile} --region ${region} | docker login --username AWS --password-stdin ${private_ecr}
  [ -z "`aws --profile ${profile} --region ${region} ecr describe-repositories | grep ${quote_name}`" ] && \
          aws ecr create-repository --profile ${profile} --region ${region} --repository-name ${name}
    docker tag ${registry}/${name}:${tag} ${private_ecr}/${name}:${tag}
    docker tag ${registry}/${name}:${tag} ${private_ecr}/${name}:${latest}
    docker push ${private_ecr}/${name}:${tag}
    docker push ${private_ecr}/${name}:${latest}
    echo "pushed: ${private_ecr}/${name}:${tag}"
}

pushDockerHub
pushPrivateECR

