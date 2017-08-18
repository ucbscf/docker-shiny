rebuild:
	docker-compose -f dev.yml build
	docker-compose -f dev.yml stop
	docker-compose -f dev.yml up -d
