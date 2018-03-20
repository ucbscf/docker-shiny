DOCKER_IMAGE = "ucbscf/docker-shiny"
SHA = $(shell git rev-parse --short HEAD)

build:
	docker build -t $(DOCKER_IMAGE):$(SHA) .

push:
	docker push $(DOCKER_IMAGE):$(SHA)

rebuild:
	docker-compose -f dev.yml build
	docker-compose -f dev.yml stop
	docker-compose -f dev.yml up -d
