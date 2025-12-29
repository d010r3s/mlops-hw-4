.PHONY: deps seed run test docs lint fix clean all

deps:
	cd dbt && dbt deps

seed:
	cd dbt && dbt seed

run:
	cd dbt && dbt run

test:
	cd dbt && dbt test

docs:
	cd dbt && dbt docs generate && dbt docs serve

lint:
	sqlfluff lint dbt/models --dialect clickhouse

fix:
	sqlfluff fix dbt/models --dialect clickhouse

clean:
	cd dbt && dbt clean

all: deps seed run test
