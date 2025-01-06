name=`basename ${PWD}`
tag=`date +%Y%m%d`01

region=ap-northeast-1
quote_name=\"${name}\"

set -xe

registry=hammer
docker build  -t ${registry}/${name}:${tag} .
#docker buildx create --driver docker-container --node armBuilder --name armBuilder
#docker buildx use armBuilder
#docker buildx build --platform linux/amd64,linux/arm64/v8 --push -t ${registry}/${name}:${tag} .
#docker buildx build --platform linux/amd64,linux/arm64/v8 --push -t ${registry}/${name}:latest .

function pushPrivateECR(){
  aws ecr get-login-password --profile ${profile} --region ${region} | docker login --username AWS --password-stdin ${private_ecr}
  [ -z "`aws --profile ${profile} --region ${region} ecr describe-repositories | grep ${quote_name}`" ] && \
          aws ecr create-repository --profile ${profile} --region ${region} --repository-name ${name}
    docker buildx build --platform linux/amd64,linux/arm64 --push -t ${private_ecr}/${name}:${tag} .
    docker buildx build --platform linux/amd64,linux/arm64 --push -t ${private_ecr}/${name}:latest .
}

#profile=carmo-dev
#private_ecr=422746423551.dkr.ecr.${region}.amazonaws.com
#pushPrivateECR

