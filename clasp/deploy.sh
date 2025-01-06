docker rm -vf cdk 
docker run -d --name cdk \
  -v ~/.aws:/home/docker/.aws \
  -v ~/.git-credentials:/home/docker/.git-credentials \
  -v ~/.gitconfig:/home/docker/.gitconfig \
  -v cdk-data:/home/docker/cdk \
  hammer/awscdkv2:latest tail -f /dev/null

