set -x
registry=valkey/
image=valkey
tag=7


public_ecr=public.ecr.aws/carmo
private_ecr=422746423551.dkr.ecr.ap-northeast-1.amazonaws.com
region=ap-northeast-1

function pushPublicECR(){
    docker tag ${registry}${image}:${tag} ${public_ecr}/${image}:${tag}
    aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${public_ecr}
    aws ecr-public create-repository --repository-name ${image} --region us-east-1
    docker push ${public_ecr}/${image}:${tag}
    echo "pushed: ${public_ecr}/${image}:${tag}"
}

function pushPrivateECR(){
    aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${private_ecr}
    aws ecr create-repository --repository-name ${image}
    docker tag ${registry}${image}:${tag} ${private_ecr}/${image}:${tag}
    docker push ${private_ecr}/${image}:${tag}
    echo "pushed: ${private_ecr}/${image}:${tag}"
}


docker pull ${registry}${image}:${tag}
pushPublicECR
