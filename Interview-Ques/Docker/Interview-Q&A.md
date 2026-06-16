1. differnce between docker add and docker copy using simple dockerfile

`ADD` and `COPY` both move files from your local machine into the Docker image, but `ADD` has extra features.

### 1. COPY (simple file copy)

Dockerfile:

```dockerfile
FROM ubuntu

COPY app.txt /opt/app.txt

CMD ["cat", "/opt/app.txt"]
```

Folder:

```text
project/
├── Dockerfile
└── app.txt
```

Build:

```bash
docker build -t copy-demo .
```

Result inside container:

```text
/opt/app.txt
```

`COPY`:

* Copies local files/directories
* Simple and predictable
* Recommended in most cases

---

### 2. ADD (copy + extract + URL support)

Dockerfile:

```dockerfile
FROM ubuntu

ADD app.tar.gz /opt/

CMD ["ls", "/opt"]
```

Folder:

```text
project/
├── Dockerfile
└── app.tar.gz
```

If `app.tar.gz` contains:

```text
logs/
config/
```

Result:

```text
/opt/logs
/opt/config
```

`ADD` automatically extracts compressed archives.

---

### URL example (ADD supports this)

```dockerfile
FROM ubuntu

ADD https://example.com/file.txt /tmp/file.txt
```

Result:

* Docker downloads `file.txt`
* Places it into `/tmp`

`COPY` cannot do this.

---

### Short interview answer

| Feature                      | COPY | ADD |
| ---------------------------- | ---- | --- |
| Copy local files             | ✅    | ✅   |
| Auto extract `.tar`          | ❌    | ✅   |
| Download from URL            | ❌    | ✅   |
| Recommended for normal usage | ✅    | ❌   |

Rule of thumb:

```text
Use COPY → normal file copy
Use ADD → only if you need tar extraction or URL download
```

---
