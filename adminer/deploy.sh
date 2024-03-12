docker rm -vf adminer
docker run --name adminer -d -p 8080:8080 -e ADMINER_PLUGINS="tables-filter dump-zip" 422746423551.dkr.ecr.ap-northeast-1.amazonaws.com/adminer:latest
