name=`basename ${PWD}`
tag=`date +%Y%m%d`01

registry=hammer
public_ecr=public.ecr.aws/carmo
private_ecr=422746423551.dkr.ecr.ap-northeast-1.amazonaws.com

docker build -t ${registry}/${name}:${tag} .

function pushDockerHub(){
    docker tag ${registry}/${name}:${tag} ${registry}/${name}:latest
    docker login
    docker push ${registry}/${name}:${tag}
    docker push ${registry}/${name}:latest
    echo "pushed: ${registry}/${name}:${tag}"
}

function pushPublicECR(){
    aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${public_ecr}
    aws ecr-public create-repository --repository-name ${name}  --region us-east-1
    docker tag ${registry}/${name}:${tag} ${public_ecr}/${name}:${tag}
    docker tag ${registry}/${name}:${tag} ${public_ecr}/${name}:latest
    docker push ${public_ecr}/${name}:${tag}
    docker push ${public_ecr}/${name}:latest
    echo "pushed: ${public_ecr}/${name}:${tag}"
}

function pushPrivateECR(){
    aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${private_ecr}
    aws ecr create-repository --repository-name ${name}
    docker tag ${registry}/${name}:${tag} ${private_ecr}/${name}:${tag}
    docker push ${private_ecr}/${name}:${tag}
    echo "pushed: ${private_ecr}/${name}:${tag}"
}

pushDockerHub
pushPublicECR
#pushPrivateECR

