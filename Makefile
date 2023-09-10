jenk-kill:
	docker container kill jenkins
jenk-build:
	docker build -t jenkins:jcasc .
jenk-run:
	docker run --env-file /home/joek2/go-workspace/src/jenkins-docker-configuration/env-creds.list \
	-u root \
	--group-add 0 \
	-v jenkins-volume1:/var/jenkins_home \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name jenkins \
	--rm -d -p 5000:8080 jenkins:jcasc
jenk-all:
	#This kills the docker container, then re-starts it
	docker container kill jenkins
	docker build -t jenkins:jcasc .
	docker run --env-file /home/joek2/go-workspace/src/jenkins-docker-configuration/env-creds.list \
	-u root \
	--group-add 0 \
	-v jenkins-volume1:/var/jenkins_home \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name jenkins \
	--rm -d -p 5000:7070 jenkins:jcasc