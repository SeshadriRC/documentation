```bash
# list the docker images
docker images

# docker build
docker build -t <image-name> .
docker build -t <image-name> -f <docker-file-location>

# run the container
docker run -p hostport:container-port <docker-image-name>
docker run -p 80:8080 --name=calculatorapp simplybyte/calculator

# list the running containers
docker ps


# using the docker hub , we will share the image to the test engineer

# login to docker
docker login


# push the docker image
docker push <repo-name>/<image-name>

# tag the image with repository name
docker tag <image-name> <repository-name>/<image-name>

docker tag <image-name> <repository-name>/<image-name>:version
docker tag calculator:1.0 simplybyte/calculator:1.0


# you developed new version
docker tag calculator:1.0 simplybyte/calculator:1.0


# pull the image
docker pull <repository-name>/<image-name>


# remove docker images
docker rmi calculator:1.0

# start the container
docker start <container-id>

# stop the container
docker stop <container-id>

# remove the container
docker rm <container-id>

# create the volume
docker volume create mycalcvolume

# list the volume
docker volume ls

# To see where the files got stored in the volume
docker volume inspect mycalcvolume

# To attach a volume to the container
docker run -p 80:8080 -v mycalculatorvolume:/data calculator:latest

```
