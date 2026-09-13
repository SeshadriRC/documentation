In **GitHub Actions**, a **matrix** lets you run the **same job multiple times with different combinations of values**.

### Simple example

Suppose you want to test your Python application on Python 3.11, 3.12, and 3.13:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: ["3.11", "3.12", "3.13"]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Run tests
        run: pytest
```

GitHub Actions effectively creates **3 job runs**:

```text
test - Python 3.11
test - Python 3.12
test - Python 3.13
```

### Multiple matrix values

You can combine dimensions:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    python-version: ["3.11", "3.12"]
```

This produces **4 combinations**:

```text
Ubuntu   + Python 3.11
Ubuntu   + Python 3.12
Windows  + Python 3.11
Windows  + Python 3.12
```

### Why use a matrix?

It avoids writing duplicate jobs.

Without matrix:

```text
Job 1 → Python 3.11
Job 2 → Python 3.12
Job 3 → Python 3.13
```

With matrix:

```text
One job definition
       ↓
     Matrix
       ↓
3 parallel executions
```

### DevOps interview answer

> **“A matrix strategy in GitHub Actions allows us to run the same job against multiple configurations, such as different operating systems, Python versions, or application versions. GitHub automatically creates a job for each combination, which helps us test across multiple environments without duplicating workflow code.”**

For your **MLOps project**, a common use would be testing your ML application against multiple **Python versions or OS environments**.

