1. Basic docker files

**Basic command**

```bash

FROM alpine

CMD ["echo", "welcome to docker"]

```

**Python basic program**

- Inside `app.py` write `print("welcome to docker")`

```bash
FROM python:3.12-slim

WORKDIR /app

COPY app.py .

CMD ["python", "app.py"]

```

**Distroless**

```bash
# Stage 1 - Builder stage
FROM python:3.12-slim AS builder

WORKDIR /app

COPY app.py .

# Stage 2 - Distroless runtime
FROM gcr.io/distroless/python3-debian12

WORKDIR /app

COPY --from=builder /app/app.py .

CMD ["/app/app.py"]

```

**If it has requirements**

```bash
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install \
--no-cache-dir \
-r requirements.txt

COPY . .

CMD ["python","app.py"]
```

--no-cache-dir → avoids pip cache → smaller image.


**Distroless requirements**

```bash
# Builder
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install \
--no-cache-dir \
--target=/python-lib \                         # Install Python packages into a specific directory instead of the default site-packages location.
-r requirements.txt

COPY app.py .

# Runtime
FROM gcr.io/distroless/python3-debian12

WORKDIR /app

COPY --from=builder /python-lib /python-lib
COPY --from=builder /app .

ENV PYTHONPATH=/python-lib

CMD ["/usr/bin/python3","/app/app.py"]
```
