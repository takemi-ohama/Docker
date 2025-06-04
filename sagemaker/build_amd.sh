name=`basename ${PWD}`
tag=`date +%Y%m%d`01
region=ap-northeast-1

set -xe

registry=hammer
public_ecr=public.ecr.aws/carmo
private_ecr=422746423551.dkr.ecr.ap-northeast-1.amazonaws.com

docker build --target=jupyter -t ${registry}/${name}-jupyter:${tag} -t ${registry}/${name}-jupyter:latest .
docker build --target=codeeditor -t ${registry}/${name}-codeeditor:${tag} -t ${registry}/${name}-codeeditor:latest .

function pushDockerHub(){
    docker push ${registry}/${name}-jupyter:${tag}
    docker push ${registry}/${name}-jupyter:latest
    docker push ${registry}/${name}-codeeditor:${tag}
    docker push ${registry}/${name}-codeeditor:latest
}

function pushPrivateECR(){
    aws ecr get-login-password --region $region | docker login --username AWS --password-stdin ${private_ecr}
    aws ecr create-repository --repository-name $1 || true
    docker tag ${registry}/$1:$2 ${private_ecr}/$1:$2
    docker push ${private_ecr}/$1:$2
}

function pushECR(){
    pushPrivateECR ${name}-jupyter ${tag}
    pushPrivateECR ${name}-jupyter latest
    pushPrivateECR ${name}-codeeditor ${tag}
    pushPrivateECR ${name}-codeeditor latest
}

pushDockerHub
pushECR
