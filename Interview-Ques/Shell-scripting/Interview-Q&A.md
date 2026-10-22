# Shell Scripting & Linux DevOps Interview Questions and Answers

A structured and comprehensive guide covering fundamental to advanced Linux shell scripting concepts, practical commands, safety practices, and real-world DevOps automation scenarios.

---

## Table of Contents

- [1. Handling Filenames with Spaces and Wildcard Characters (Variable Quoting)](#1-handling-filenames-with-spaces-and-wildcard-characters-variable-quoting)
- [2. Counting Matching Lines Safely Without Printing (`grep -c`)](#2-counting-matching-lines-safely-without-printing-grep--c)
- [3. Creating Unique Temporary Files Securely (`mktemp`)](#3-creating-unique-temporary-files-securely-mktemp)
- [4. Filtering Specific Error Patterns from Log Files (e.g., Oracle `ORA-` Errors)](#4-filtering-specific-error-patterns-from-log-files-eg-oracle-ora--errors)
- [5. Script to Print Date and Name Every 5 Seconds Using an Environment Variable](#5-script-to-print-date-and-name-every-5-seconds-using-an-environment-variable)
- [6. Script to Delete All Docker Images Scheduled via Crontab (e.g., Wednesdays)](#6-script-to-delete-all-docker-images-scheduled-via-crontab-eg-wednesdays)
- [7. Commonly Used Linux Shell Commands](#7-commonly-used-linux-shell-commands)
- [8. What is `awk` and How is it Used?](#8-what-is-awk-and-how-is-it-used)
- [9. Script to Print Only Errors from a Remote Log File](#9-script-to-print-only-errors-from-a-remote-log-file)
- [10. Understanding the Linux Pipe (`|`) Operator](#10-understanding-the-linux-pipe--operator)
- [11. Difference Between `curl` and `wget`](#11-difference-between-curl-and-wget)
- [12. Shell Script to Print Numbers Divisible by 3 and 5 but Not 15 (1..100)](#12-shell-script-to-print-numbers-divisible-by-3-and-5-but-not-15-1100)
- [13. Script to Check Each File in Directory for Content (Empty vs Not Empty)](#13-script-to-check-each-file-in-directory-for-content-empty-vs-not-empty)
- [14. Script to Check Whether the Current Directory is Empty](#14-script-to-check-whether-the-current-directory-is-empty)
- [15. Shell Test Operators: `-z`, `-s`, and `-f`](#15-shell-test-operators--z--s-and--f)
- [16. Understanding `set -euo pipefail` (Bash Strict Mode)](#16-understanding-set--euo-pipefail-bash-strict-mode)
- [17. Understanding the `trap` Command and Signal Handling](#17-understanding-the-trap-command-and-signal-handling)
- [18. Understanding `IFS` (Internal Field Separator)](#18-understanding-ifs-internal-field-separator)
- [19. Difference Between `IFS` and `awk`](#19-difference-between-ifs-and-awk)

---

## 1. Handling Filenames with Spaces and Wildcard Characters (Variable Quoting)

**Question:** Your script receives a filename that may include spaces and wildcard characters (such as `*`, `?`, or `[]`). Which approach is best?

**Answer:**  
Always enclose variable references in **double quotes** (`"$file"`).

```bash
file="my data*.txt"

# Safe: double quotes prevent word-splitting and unexpected globbing expansion
cat "$file"
```

### Why Quoting Matters:
- Without quotes (`cat $file`), the shell performs **word splitting** (splitting on spaces) and **pathname expansion / globbing** (expanding `*` to match files in the directory).
- If `$file` is `"my data*.txt"`, unquoted `cat $file` executes `cat my data1.txt data2.txt`, causing missing file errors or reading unintended files.
- Double quotes ensure the variable value is passed to the command as a single literal argument.

> **Interview One-Liner:**  
> "Always quote variables (`\"$var\"`) to prevent unwanted word splitting on whitespace and unintentional glob expansion on wildcard characters."

[⬆ Back to Top](#table-of-contents)

---

## 2. Counting Matching Lines Safely Without Printing (`grep -c`)

**Question:** Which command safely counts the number of matching lines in a file without printing the matching lines themselves?

**Answer:**  
Use `grep -c`.

```bash
grep -c "ERROR" app.log
```

### Example:
```bash
$ cat error.log
ERROR Connection failed
INFO Service started
ERROR Timeout

$ grep -c "ERROR" error.log
2
```

### Why not `grep "ERROR" app.log | wc -l`?
- `grep -c` executes in a **single process** without the overhead of creating a subshell, pipeline, and spawning `wc`.
- It directly returns the count and sets the exit status appropriately (0 if count > 0, 1 if count == 0).

[⬆ Back to Top](#table-of-contents)

---

## 3. Creating Unique Temporary Files Securely (`mktemp`)

**Question:** Which command creates a uniquely named temporary file safely in Bash scripts to avoid naming collisions and symlink vulnerabilities?

**Answer:**  
Use `mktemp`.

```bash
# Creates a unique temporary file in /tmp (e.g., /tmp/tmp.T7RjgLaxtN)
temp_file=$(mktemp)

echo "temporary payload" > "$temp_file"

# Always ensure cleanup on script exit
trap 'rm -f "$temp_file"' EXIT
```

### Advanced Usage:
```bash
# Create a unique temporary directory
temp_dir=$(mktemp -d)

# Create a temporary file with a custom prefix/template
temp_file=$(mktemp /tmp/myapp_backup.XXXXXX)
```

> **Interview One-Liner:**  
> "`mktemp` creates unique, unpredictable temporary files or directories with restrictive permissions (0600), preventing race conditions and naming collisions."

[⬆ Back to Top](#table-of-contents)

---

## 4. Filtering Specific Error Patterns from Log Files (e.g., Oracle `ORA-` Errors)

**Question:** Assume there is a log file (`ora.logs`) containing Oracle database errors. How do you print only the ORA error codes or matching lines?

### Approach 1: Print Only the Exact Matching Error Code (`-o`)
```bash
# -o prints only the matched part of the line
grep -o "ORA-00019" ora.logs
```

### Approach 2: Extract Any ORA Error Code Using Extended Regular Expressions (`-oE`)
```bash
# Matches 'ORA-' followed by one or more digits
grep -oE "ORA-[0-9]+" ora.logs
```

### Approach 3: Print the Entire Line Containing Any ORA Error
```bash
grep -E "ORA-[0-9]+" ora.logs
```

[⬆ Back to Top](#table-of-contents)

---

## 5. Script to Print Date and Name Every 5 Seconds Using an Environment Variable

**Question:** Write a shell script that prints today's date along with a name at an interval of 5 seconds, where the name is passed as an environment variable.

```bash
#!/bin/bash

# Validate that the environment variable is set
if [[ -z "${NAME:-}" ]]; then
    echo "ERROR: Environment variable 'NAME' is not set."
    echo "Usage: export NAME='DevOps Engineer' && ./script.sh"
    exit 1
fi

echo "Starting monitoring loop for: $NAME (Press Ctrl+C to stop)"

while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $NAME"
    sleep 5
done
```

### Running the Script:
```bash
export NAME="Seshadri"
./script.sh
```

### Output:
```text
2026-10-20 19:30:00 - Seshadri
2026-10-20 19:30:05 - Seshadri
2026-10-20 19:30:10 - Seshadri
```

[⬆ Back to Top](#table-of-contents)

---

## 6. Script to Delete All Docker Images Scheduled via Crontab (e.g., Wednesdays)

**Question:** Write a shell script to remove all Docker images, log the output, and schedule it via crontab to run every Wednesday at 2:00 AM.

### 1. Cleanup Script (`/home/ec2-user/cleanup_docker_images.sh`)
```bash
#!/bin/bash
set -euo pipefail

LOGFILE="/var/log/docker_image_cleanup.log"

echo "==========================================" >> "$LOGFILE"
echo "Docker Image Cleanup Started: $(date)"     >> "$LOGFILE"

# Collect image IDs
IMAGES=$(docker images -q)

# n checks string is not empty
if [[ -n "$IMAGES" ]]; then 
    # Force remove all Docker images and redirect both stdout and stderr to the log
    docker rmi -f $IMAGES >> "$LOGFILE" 2>&1
    echo "Docker images removed successfully." >> "$LOGFILE"
else
    echo "No Docker images found to remove." >> "$LOGFILE"
fi

echo "Docker Image Cleanup Completed: $(date)"   >> "$LOGFILE"
echo "==========================================" >> "$LOGFILE"
```

### 2. Crontab Schedule
Edit crontab with `crontab -e`:

```cron
0 2 * * 3 /bin/bash /home/ec2-user/cleanup_docker_images.sh
```

### Crontab Syntax Breakdown:

| Field | Value | Meaning |
| :--- | :--- | :--- |
| **Minute** | `0` | At minute 0 |
| **Hour** | `2` | At 02:00 AM (24-hour format) |
| **Day of Month** | `*` | Every day of the month |
| **Month** | `*` | Every month |
| **Day of Week** | `3` | Wednesday (0 = Sun, 1 = Mon, 2 = Tue, 3 = Wed, ...) |

[⬆ Back to Top](#table-of-contents)

---

## 7. Commonly Used Linux Shell Commands

A quick reference of essential commands for day-to-day DevOps operations, troubleshooting, and administration:

```bash
# File and Directory Navigation
ls -la                              # List all files including hidden with permissions and details
mkdir -p /path/to/dir               # Create directory with parent directories
cat file.txt                        # View entire file contents
cp -r source/ destination/          # Copy files or directories recursively
mv old_name new_name                # Move or rename files/directories
vi filename                         # Standard text editor

# Permissions & Ownership
chmod 755 script.sh                 # Change file permissions (rwxr-xr-x)
chown user:group filename           # Change file owner and group

# Disk & System Monitoring
df -h                               # Check disk space usage in human-readable format
top                                 # Monitor real-time system resource usage (CPU/RAM)
ps -ef                              # List all running processes with full details

# Search & Text Processing
grep -i "error" app.log             # Case-insensitive pattern search
awk '{print $1}' data.txt           # Column-based text extraction

# Compression & Archives
zip -r archive.zip folder/          # Create zip archive
unzip archive.zip                   # Extract zip archive

# Networking & Connectivity
netstat -tulnp | grep 9000          # Display listening ports (legacy)
ss -tulnp | grep 9000               # Modern socket statistics replacement for netstat
nc -zv 10.1.1.20 9000               # Test TCP connectivity to IP and port
```

[⬆ Back to Top](#table-of-contents)

---

## 8. What is `awk` and How is it Used?

`awk` is a complete pattern-scanning and text-processing language in Linux used to search, filter, extract, and manipulate columns/fields from structured text data (such as logs, CSVs, and command outputs).

By default, `awk` divides each input line into fields separated by whitespace (spaces or tabs), accessible via `$1`, `$2`, ..., `$NF` (last field), and `$0` (the entire line).

### Common Examples

1. **Extract specific columns:**
   ```bash
   echo "John 25 Engineer" | awk '{print $1, $3}'
   # Output: John Engineer
   ```

2. **Extract process owner from `ps -ef`:**
   ```bash
   ps -ef | awk '{print $1}'
   ```

3. **Custom Delimiter (e.g., CSV or Colon-separated):**
   ```bash
   # Extract username and shell from /etc/passwd using ':' delimiter
   awk -F: '{print $1, $7}' /etc/passwd
   ```

4. **Filtering with conditions:**
   ```bash
   # Print lines where the 3rd field is greater than 100
   awk '$3 > 100 {print $1, $3}' data.txt
   ```

> **Interview One-Liner:**  
> "`awk` is a complete text-processing tool ideal for parsing structured tabular data, extracting columns, applying conditional filters, and generating formatted reports."

[⬆ Back to Top](#table-of-contents)

---

## 9. Script to Print Only Errors from a Remote Log File

When troubleshooting distributed applications, you often need to fetch logs from a remote endpoint or artifact repository and filter for critical events without downloading the entire file to disk first.

```bash
curl -s https://raw.githubusercontent.com/SeshadriRC/sandbox/refs/heads/main/log/dummylog01122022.log | grep -i error
```

### Explanation:
- `curl -s`: Runs in silent mode (hides progress meters and error messages).
- `|` (Pipe): Streams the HTTP response body directly into `grep` without writing a temporary file to disk.
- `grep -i error`: Case-insensitive search matching `ERROR`, `error`, `Error`, etc.

[⬆ Back to Top](#table-of-contents)

---

## 10. Understanding the Linux Pipe (`|`) Operator

The pipe operator (`|`) in Linux is used to **take the standard output (stdout) of one command and pass it as standard input (stdin) to another command**. It enables command chaining and building powerful modular pipelines.

### Syntax
```bash
command1 | command2 | command3
```

### Practical Examples

1. **Filter running processes:**
   ```bash
   ps -ef | grep java
   ```
   - `ps -ef`: Lists all active processes.
   - `|`: Passes the process list to `grep`.
   - `grep java`: Filters and displays only lines matching "java".

2. **Count number of files in a directory:**
   ```bash
   ls -1 | wc -l
   ```
   - `ls -1`: Lists one file per line.
   - `wc -l`: Counts total lines, giving the exact file count.

3. **Find the top 5 memory-consuming processes:**
   ```bash
   ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6
   ```

> **Interview One-Liner:**  
> "A pipe (`|`) connects the `stdout` of the command on its left directly to the `stdin` of the command on its right, allowing commands to work together without intermediate temporary files."

[⬆ Back to Top](#table-of-contents)

---

## 11. Difference Between `curl` and `wget`

Both `curl` and `wget` are command-line utilities used for transferring data via network protocols (HTTP, HTTPS, FTP), but they have different strengths and primary purposes:

| Feature | `curl` | `wget` |
| :--- | :--- | :--- |
| **Primary Purpose** | Transferring data to/from APIs and URLs | Downloading files and mirroring sites |
| **HTTP Methods** | GET, POST, PUT, DELETE, PATCH, HEAD, etc. | Primarily GET and POST |
| **API Testing & Custom Headers** | Excellent (supports payload, custom headers, auth) | Limited |
| **Default Output** | Prints directly to `stdout` (terminal) | Saves directly to a file on disk |
| **Recursive Download** | No | Yes (`wget -r` can mirror entire websites) |
| **Resume Downloads** | Supported via `-C -` | Supported via `-c` |
| **Underlying Engine** | Powered by `libcurl` (usable as a C library) | Standalone command-line tool |

### Quick Examples

#### `curl` Examples (API Interaction & Connectivity)
```bash
# Basic GET request (prints output to terminal)
curl http://server:8080

# Send POST request with JSON payload
curl -X POST http://api.example.com/users \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice"}'

# Fetch only HTTP response headers (check status code)
curl -I https://google.com
```

#### `wget` Examples (File Downloading)
```bash
# Download a file directly to the current directory
wget https://example.com/package.zip

# Resume an interrupted download
wget -c https://example.com/largefile.tar.gz

# Recursively download/mirror a directory
wget -r -np -nH https://example.com/docs/
```

> **Interview One-Liner:**  
> "`curl` is best for communicating with APIs, testing HTTP methods, and streaming responses, whereas `wget` is optimized for downloading files, resuming broken transfers, and recursive website mirroring."

[⬆ Back to Top](#table-of-contents)

---

## 12. Shell Script to Print Numbers Divisible by 3 and 5 but Not 15 (1..100)

**Problem:** Loop through numbers from 1 to 100. Print numbers that are divisible by 3 OR 5, but NOT divisible by 15.

```bash
#!/bin/bash

for i in {1..100}; do
    if (( (i % 3 == 0 || i % 5 == 0) && i % 15 != 0 )); then
        echo "$i"
    fi
done
```

### Explanation:
- `{1..100}`: Bash brace expansion generating numbers 1 to 100.
- `(( ... ))`: Arithmetic evaluation syntax in Bash.
- `i % 3 == 0 || i % 5 == 0`: True if divisible by 3 OR divisible by 5.
- `i % 15 != 0`: Excludes numbers that are common multiples of both (i.e., 15, 30, 45, 60, 75, 90).

[⬆ Back to Top](#table-of-contents)

---

## 13. Script to Check Each File in Directory for Content (Empty vs Not Empty)

**Problem:** Inspect every item in the current directory, verify that it is a regular file, and determine whether it contains content or is empty.

```bash
#!/bin/bash

for file in *; do
    if [ -f "$file" ]; then
        if [ -s "$file" ]; then
            echo "$file → Not Empty (Size > 0)"
        else
            echo "$file → Empty (Size == 0)"
        fi
    fi
done
```

### Explanation:
- `for file in *`: Iterates over all visible entries in the current directory.
- `[ -f "$file" ]`: Ensures we only evaluate regular files (skipping subdirectories, sockets, and symlinks).
- `[ -s "$file" ]`: Returns true if the file exists and has a size greater than zero.

[⬆ Back to Top](#table-of-contents)

---

## 14. Script to Check Whether the Current Directory is Empty

```bash
#!/bin/bash

if [ -z "$(ls -A)" ]; then
    echo "Directory is empty"
else
    echo "Directory is not empty"
fi
```

### Step-by-Step Breakdown:

1. **`ls -A`**:
   - Lists all entries in the directory, including hidden files (like `.env`, `.git`).
   - Ignores `.` (current directory) and `..` (parent directory).
   - If the directory has no files, `ls -A` outputs nothing (`""`).

2. **`$(ls -A)` (Command Substitution)**:
   - Executes `ls -A` and replaces itself with the command's stdout.

3. **`[ -z "..." ]`**:
   - The `-z` operator tests whether a string has a length of zero.
   - If `$(ls -A)` produced nothing, `[ -z "" ]` evaluates to **true** $\rightarrow$ "Directory is empty".
   - If files exist, `$(ls -A)` produces text, `[ -z "text" ]` evaluates to **false** $\rightarrow$ "Directory is not empty".

[⬆ Back to Top](#table-of-contents)

---

## 15. Shell Test Operators: `-z`, `-s`, and `-f`

These are conditional file and string test operators used inside `[ ]` (test) or `[[ ]]` (extended test) in Bash.

### 1. `-z string` $\rightarrow$ Checks if string is EMPTY (length == 0)
```bash
name=""

if [ -z "$name" ]; then
    echo "String is empty"
fi
```

### 2. `-s file` $\rightarrow$ Checks if file has CONTENT (size > 0)
```bash
touch app.log
[ -s app.log ]        # Returns FALSE (0 bytes)

echo "hello" > app.log
[ -s app.log ]        # Returns TRUE (> 0 bytes)
```

### 3. `-f file` $\rightarrow$ Checks if path exists and is a REGULAR FILE
```bash
touch app.log
mkdir logs

[ -f app.log ]        # Returns TRUE (regular file)
[ -f logs ]           # Returns FALSE (it is a directory, not a regular file)
```

### Quick Operator Reference Table

| Operator | Evaluates To True If: | Example |
| :--- | :--- | :--- |
| **`-z`** | String length is zero (empty) | `[ -z "$var" ]` |
| **`-n`** | String length is non-zero (not empty) | `[ -n "$var" ]` |
| **`-s`** | File exists and has size greater than 0 | `[ -s "$file" ]` |
| **`-f`** | Path exists and is a regular file | `[ -f "$file" ]` |
| **`-d`** | Path exists and is a directory | `[ -d "$dir" ]` |
| **`-e`** | Path exists (file, directory, socket, etc.) | `[ -e "$path" ]` |
| **`-r`** | File exists and is readable | `[ -r "$file" ]` |
| **`-w`** | File exists and is writable | `[ -w "$file" ]` |
| **`-x`** | File exists and is executable | `[ -x "$script" ]` |

[⬆ Back to Top](#table-of-contents)

---

## 16. Understanding `set -euo pipefail` (Bash Strict Mode)

`set -euo pipefail` is known as the **Bash Unofficial Strict Mode**. It prevents scripts from continuing after failures, catching bugs early before they cause data corruption or cascading errors.

It is equivalent to configuring:
```bash
set -e
set -u
set -o pipefail
```

### Breakdown of Each Flag:

#### 1. `set -e` (Exit on error)
Tells Bash to immediately exit if any command exits with a non-zero exit status.
- **Without `-e`:** If `mkdir /root/backup` fails due to permissions, the script continues to `rm -rf /root/data`, potentially causing disaster.
- **With `-e`:** The script terminates immediately upon the first failure.

#### 2. `set -u` (Treat unset variables as errors)
Tells Bash to treat unset/undefined variables as fatal errors and exit immediately.
- **Without `-u`:** If you make a typo like `rm -rf /tmp/$drectory/`, and `$drectory` is unset, it evaluates to `rm -rf /tmp//`!
- **With `-u`:** Bash exits with `bash: drectory: unbound variable`.

#### 3. `set -o pipefail` (Pipeline failure detection)
By default, Bash only checks the exit status of the **last command** in a pipeline.
- **Without `pipefail`:**
  ```bash
  cat nonexistent.txt | wc -l
  echo $?
  # Output: 0 (wc -l succeeded, masking cat's failure!)
  ```
- **With `pipefail`:**
  ```bash
  set -o pipefail
  cat nonexistent.txt | wc -l
  echo $?
  # Output: 1 (The entire pipeline fails because 'cat' failed)
  ```

> **Interview Explanation:**  
> "I use `set -euo pipefail` in production automation scripts to enforce strict error handling. It ensures the script aborts immediately on command failures (`-e`), prevents execution with typos or undefined variables (`-u`), and surfaces errors from any stage of a pipeline (`pipefail`)."

[⬆ Back to Top](#table-of-contents)

---

## 17. Understanding the `trap` Command and Signal Handling

The `trap` command in Bash allows you to **catch system signals or script exit events and execute cleanup or rollback logic automatically**.

### Syntax
```bash
trap 'command_or_function' SIGNAL [SIGNAL...]
```

### Common Signals Caught by `trap`

| Signal | Signal Number | Trigger Event |
| :--- | :--- | :--- |
| **`INT`** | 2 | Interrupt from keyboard (`Ctrl + C`) |
| **`TERM`** | 15 | Termination signal (e.g., `kill <pid>`) |
| **`EXIT`** | 0 | Normal or abnormal exit of the shell script |
| **`ERR`** | - | Any command returning a non-zero exit code |

### Example 1: Catching `Ctrl + C` (INT) for Safe Cleanup
```bash
#!/bin/bash

cleanup() {
    echo -e "\n[!] Script interrupted by user. Cleaning up temp files..."
    rm -f /tmp/temp_data_$$.txt
    exit 1
}

# Register the trap
trap cleanup INT

echo "Long-running process started. Press Ctrl+C to abort..."
touch /tmp/temp_data_$$.txt
sleep 60
```

### Example 2: Automatic Cleanup on `EXIT`
```bash
#!/bin/bash

TEMP_DIR=$(mktemp -d)
# Automatically remove the temporary directory when the script finishes or exits
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Working inside temporary directory: $TEMP_DIR"
# Work happens here...
```

### Real DevOps Interview Scenario: Rollback on Git Automation

In an automated Git release or decommission script, if the script is interrupted halfway through, you could leave an uncommitted branch or modified working tree. A `trap` ensures automatic rollback:

```bash
cleanup_branch() {
    echo "[!] Interrupted! Rolling back git repository state..."
    git checkout master
    git branch -D "$branch_name" 2>/dev/null || true
    git reset --hard origin/master
    exit 1
}

trap cleanup_branch INT TERM
```

> **Interview Explanation:**  
> "`trap` allows scripts to intercept signals such as `SIGINT` (Ctrl+C), `SIGTERM`, or `EXIT`. I use it to implement idempotent cleanup routines—such as deleting temporary directories, restoring Git branches, or closing active sessions—preventing orphaned resources or inconsistent states."

[⬆ Back to Top](#table-of-contents)

---

## 18. Understanding `IFS` (Internal Field Separator)

`IFS` (Internal Field Separator) is a special shell environment variable that defines **which character(s) Bash uses to split strings into words or fields** during word splitting and the `read` command.

By default, `IFS` consists of whitespace characters:
- Space (`' '`)
- Tab (`'\t'`)
- Newline (`'\n'`)

### Example 1: Default `IFS` Behavior
```bash
names="Alice Bob Charlie"
for name in $names; do
    echo "$name"
done
# Splits on spaces:
# Alice
# Bob
# Charlie
```

### Example 2: Parsing CSV Records (`IFS=','`)
```bash
line="production,us-east-1,payment-service"

IFS=',' read -r env region app <<< "$line"

echo "Environment: $env"
echo "Region:      $region"
echo "Application: $app"
```

### Example 3: Processing CSV Files Row-by-Row
```bash
while IFS=',' read -r base cluster ns; do
    echo "Cluster: $cluster, Namespace: $ns"
done < clusters.csv
```

### Preserving Leading/Trailing Whitespace with `IFS=`
When reading lines without wanting Bash to trim leading and trailing spaces:
```bash
while IFS= read -r line; do
    echo "$line"
done < indented_code.yaml
```

> **Interview One-Liner:**  
> "`IFS` determines how Bash separates fields when tokenizing input. By temporarily setting `IFS=','` or `IFS=':'`, we can cleanly parse delimited files like CSVs or `/etc/passwd` without resorting to external utilities."

[⬆ Back to Top](#table-of-contents)

---

## 19. Difference Between `IFS` and `awk`

While both `IFS` and `awk` are used to split and process structured text, they operate at fundamentally different levels:

| Feature | `IFS` (Internal Field Separator) | `awk` |
| :--- | :--- | :--- |
| **What is it?** | A built-in shell variable in Bash | A standalone programming language & CLI tool |
| **Execution** | Built directly into the shell (zero process overhead) | Spawns an external process (`/usr/bin/awk`) |
| **Primary Use** | Splitting input strings/lines in `read` or loops | Advanced pattern matching, field math, filtering, formatting |
| **Capabilities** | Simple field delimiter configuration | Conditions, loops, associative arrays, regex, built-in functions |
| **Performance** | Best for lightweight, in-shell line iteration | Faster for processing large multi-megabyte log files |

### When to Use Which?
- **Use `IFS`:** When writing bash loops to iterate line-by-line over small-to-medium CSV files and running bash functions or commands on each field.
- **Use `awk`:** When filtering, calculating, or transforming large structured datasets, log files, or command outputs before piping to other tools.

> **Interview One-Liner:**  
> "`IFS` is a shell variable for controlling how the shell tokenizes words and reads lines into variables. `awk` is a full-featured text-processing engine designed for pattern scanning, arithmetic calculations, column extraction, and report formatting."

[⬆ Back to Top](#table-of-contents)
