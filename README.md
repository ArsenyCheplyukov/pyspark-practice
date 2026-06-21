# PySpark Polygon

Изолированный полигон PySpark в Docker.

- **JDK**: Eclipse Temurin 21 (Spark 4.1.2 официально поддерживает только 17 и 21).
- **Python**: 3.13.
- **PySpark**: `4.1.2` (проверено на PyPI, текущая latest).
- **Менеджер зависимостей**: `uv` + `pyproject.toml`.
- **Jupyter Lab**: порт `8888`.
- **Spark UI**: порт `4040`.

## Быстрый старт

```bash
docker compose up -d --build
```

После сборки:

- Jupyter Lab: http://localhost:8888 (без токена).
- Spark UI: http://localhost:4040 (появляется, пока работает Spark-приложение).

## VS Code Attach

1. Установи расширение **Dev Containers**.
2. `F1` → `Dev Containers: Attach to Running Container...`
3. Выбери контейнер `pyspark-polygon`.
4. Открой внутри контейнера папку `/workspace`.

Код правь в `./workspace` на хосте — изменения сразу видны внутри контейнера, перезапуск не нужен.

## Пример Spark-сессии

```python
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("polygon")
    .config("spark.driver.bindAddress", "0.0.0.0")
    .getOrCreate()
)

spark.range(10).show()
```

После запуска сессии Spark UI будет доступен на http://localhost:4040.

## Зависимости

Запинены в `pyproject.toml`:

```toml
dependencies = [
    "pyspark==4.1.2",
    "pyarrow>=15",
    "pandas>=2.2",
    "jupyterlab>=4.3",
]
```

Чтобы изменить зависимости:

1. Отредактируй `pyproject.toml`.
2. Пересобери образ:

```bash
docker compose up -d --build
```

## Остановка

```bash
docker compose down
```
