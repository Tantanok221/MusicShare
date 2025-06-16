.PHONY: dev

dev:
	./bin/dev

db_check:
	PGPASSWORD=admin psql -h localhost -U postgres -d musicshare_development

db_up:
	docker-compose up -d