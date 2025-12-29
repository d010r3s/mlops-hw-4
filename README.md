# Домашка №4 MLOps
##### Торговкина Мария

#### Запуск:
!! нужно вручную положить `train.csv` в папку `data/`, он слишком тяжелый, чтобы залить на гитхаб
```bash
python -m venv .venv
source .venv/bin/activate  # или .venv\Scripts\activate
pip install -r requirements.txt
docker compose up -d
dbt deps
dbt seed
dbt run
dbt test # тут будут generic singular unit
dbt docs generate
dbt docs serve # скриншот прикрепила
```

