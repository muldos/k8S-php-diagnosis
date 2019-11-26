
Building and pushing the image to aws ecr: 
`aws ecr get-login --no-include-email --region <your-region> --profile <your-profile>`
Then execute the outputed `docker login` command.

`docker build -f images\prod\Dockerfile -t php-hello .`

`docker tag php-hello xxx.dkr.ecr.eu-west-1.amazonaws.com/php-hello:1.2`

`docker push xxx.dkr.ecr.eu-west-1.amazonaws.com/php-hello:1.2`