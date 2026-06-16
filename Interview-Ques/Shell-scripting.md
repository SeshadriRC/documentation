1. List some of the commonly used shell commands


```bash
ls
cat
df -h
mkdir
vi
grep
cp
mv
chmod
chown
top
zip
unzip
netstat -tulnp | grep 9000    # used to display listening ports
ss -tulnp | grep 9000         # modern usage of netstat
nc -zv 10.1.1.20 9000  # connectivity test
ps -ef    # to list all the processes

```

---

2. what is awk ?

- `awk` is a text-processing command in Linux used to search, filter, extract, and manipulate columns/fields from structured text.

```bash
echo "John 25" | awk '{print $1}'


ps -ef|awk '{print $1}'
```

---

3. Write a script to print only errors from a remote log

```bash
curl https://raw.githubusercontent.com/SeshadriRC/sandbox/refs/heads/main/log/dummylog01122022.log | grep -i error
```

---

4. what is pipe command in linux

```bash
`|` (pipe) in Linux is used to **take the output of one command and pass it as input to another command.**

Syntax:

```bash id="2yshzd"
command1 | command2
```

Example:

```bash id="mv7h3q"
ps -ef | grep java
```

Meaning:

* `ps -ef` → lists processes
* `|` → sends output
* `grep java` → filters only Java processes

Output:

```text id="g2wlnc"
root  1234 ... java
```

Another example:

```bash id="0f8ybh"
ls | wc -l
```

Meaning:

* `ls` → list files
* `wc -l` → count lines (number of files)

So `|` = **output of left command → input to right command**.

---

5. Difference between curl and wget


`curl` and `wget` are both used to **transfer data from URLs**, but they are optimized for different use cases.

| Feature                    | `curl`                               | `wget`                |
| -------------------------- | ------------------------------------ | --------------------- |
| Main purpose               | Send/receive data from APIs and URLs | Download files        |
| HTTP methods               | GET, POST, PUT, DELETE, etc.         | Mostly GET            |
| API testing                | Excellent                            | Limited               |
| Download resume            | Supported                            | Supported             |
| Recursive website download | No                                   | Yes                   |
| Upload files               | Yes                                  | Limited               |
| Output                     | Prints to terminal by default        | Saves file by default |

### `curl` → API / connectivity testing

Example:

```bash id="k0y4vl"
curl http://server:8080
```

POST request:

```bash id="3sm4rz"
curl -X POST http://api.com
```

Check connectivity:

```bash id="d75nqa"
curl -I http://google.com
```

---

### `wget` → Download files

Download:

```bash id="7bb72d"
wget https://example.com/file.zip
```

Resume:

```bash id="z1v6r8"
wget -c file_url
```

Recursive download:

```bash id="6dzl5q"
wget -r https://example.com
```

Interview one-liner:

* **`curl` → interact with APIs / send requests**
* **`wget` → download files from internet**

---

6. Write a shell script to print numbers divided by 3 & 5 and not 15. Range is 1...100

<img width="626" height="277" alt="image" src="https://github.com/user-attachments/assets/b5daef71-d797-44b1-b9e0-6d23de20bd19" />

```bash
#!/bin/bash

for i in {1..100}
do
    if (( (i % 3 == 0 || i % 5 == 0) && i % 15 != 0 ))
    then
        echo $i
    fi
done
```

---

7. If you want to check each file in the current directory and identify whether the file has content or is empty, use:


```bash
#!/bin/bash
for file in *; do
    if [ -f "$file" ]; then
        if [ -s "$file" ]; then
            echo "$file → Not Empty"
        else
            echo "$file → Empty"
        fi
    fi
done
```

---

8. check whether the current directory contains files or not

```bash
if [ -z "$(ls -A)" ]; then
    echo "Directory is empty"
else
    echo "Directory is not empty"
fi
```

This is a **shell script conditional statement** that checks whether the **current directory is empty or not**.

Let's break it line by line:

```bash
if [ -z "$(ls -A)" ]; then
```

### 1. `ls -A`

Lists files in the current directory.

Example:

```bash
$ ls -A
file1.txt
file2.txt
```

If directory is empty:

```bash
$ ls -A
(no output)
```

`-A` means:

* show hidden files too (`.env`, `.gitignore`)
* but ignore `.` and `..`


### 2. `$(ls -A)`

This is **command substitution**.

It runs:

```bash
ls -A
```

and replaces it with the output.

Example:

```bash
$(ls -A)
```

becomes:

```bash
"file1.txt file2.txt"
```

If empty:

```bash
""
```

### 3. `[ -z "..." ]`

`-z` means:

> Check whether string length is zero.

Examples:

```bash
[ -z "" ]
```

→ TRUE

```bash
[ -z "abc" ]
```

→ FALSE


So:

```bash
if [ -z "$(ls -A)" ];
```

means:

> "Run `ls -A`, and if output length is zero → directory is empty"


Then:

```bash
then
    echo "Directory is empty"
```

Prints:

```text
Directory is empty
```

Otherwise:

```bash
else
    echo "Directory is not empty"
```

Prints:

```text
Directory is not empty
```

Finally:

```bash
fi
```

`fi` = closes the `if` block (`if` spelled backward).


Flow:

```text
ls -A
   ↓
Any files?
   ↓
No → -z TRUE → Directory is empty
Yes → else → Directory is not empty
```


9. what is -z , -s, -f


 These are **test operators** used inside `[ ]` in shell scripting.

Example:

```bash id="ayt2dg"
if [ condition ]; then
   commands
fi
```

### 1. `-z` → Check whether a string is empty

Syntax:

```bash id="o5p6nq"
[ -z "string" ]
```

Example:

```bash id="y62vzx"
name=""

if [ -z "$name" ]; then
    echo "String is empty"
fi
```

Output:

```text id="3tcc8e"
String is empty
```

Another example:

```bash id="dftv4f"
name="hello"

[ -z "$name" ]
```

→ FALSE (because string has value)


### 2. `-s` → Check whether a file has content (size > 0)

Syntax:

```bash id="lcnldc"
[ -s filename ]
```

Example:

```bash id="6k0on4"
touch a.txt

[ -s a.txt ]
```

→ FALSE (empty file)

Now:

```bash id="6j4uwu"
echo hello > a.txt

[ -s a.txt ]
```

→ TRUE

Example:

```bash id="s7vq1x"
if [ -s a.txt ]; then
   echo "File has content"
fi
```

### 3. `-f` → Check whether it is a regular file

Syntax:

```bash id="0f80lu"
[ -f filename ]
```

Example:

```bash id="iw7z2d"
touch app.log
mkdir logs

[ -f app.log ]
```

→ TRUE

```bash id="3l4u6l"
[ -f logs ]
```

→ FALSE (because logs is directory)

Example:

```bash id="ix4vnq"
if [ -f a.txt ]; then
   echo "This is a file"
fi
```


Quick summary:

| Operator | Meaning             | Example           |
| -------- | ------------------- | ----------------- |
| `-z`     | String is empty     | `[ -z "$name" ]`  |
| `-s`     | File has content    | `[ -s file.txt ]` |
| `-f`     | Regular file exists | `[ -f file.txt ]` |

Some other common ones:

```bash id="2bc4vv"
-d   → directory exists
-e   → file exists
-r   → readable
-w   → writable
-x   → executable
```


---

10. what is set -euo pipefail

`set -euo pipefail` is a **Bash safety configuration**.
It makes scripts fail fast and avoid hidden errors.

Your script:

```bash id="6ntr4m"
set -euo pipefail
```

is equivalent to:

```bash id="g7ig2z"
set -e
set -u
set -o pipefail
```

Let's break it down.


## 1. `set -e`

### Exit immediately if a command fails.

Example:

```bash id="dy2jpj"
echo "Start"

mkdir test
mkdir test

echo "Done"
```

Without `-e`:

```text id="iv6qmb"
Start
mkdir: File exists
Done
```

Script continues.

With `set -e`:

```text id="w2xqrm"
Start
mkdir: File exists
```

Script stops immediately.


## 2. `set -u`

### Treat undefined variables as errors.

Example:

```bash id="x28lfn"
echo "$username"
```

Without `-u`:

Output:

```text id="3i6q4u"
```

(empty)

With `set -u`:

```text id="fg7fq0"
bash: username: unbound variable
```

Stops script.

Useful to catch typos.

Example:

Wrong:

```bash id="l70ivk"
echo "$clustr"
```

instead of:

```bash id="d5ly2k"
echo "$cluster"
```


## 3. `set -o pipefail`

### Detect failures inside pipelines (`|`)

Example:

```bash id="1m1m4w"
cat missing.txt | grep abc
```

Without `pipefail`:

Pipeline may appear successful because `grep` runs.

With `pipefail`:

If `cat` fails → whole pipeline fails.

Example:

```bash id="dkh3ck"
cat missing.txt | wc -l
```

Without:

```text id="4x4h6d"
0
```

Looks successful.

With `pipefail`:

```text id="gg0cqf"
cat: missing.txt
Script stopped
```


### Why useful in your namespace deletion script?

```bash id="j89lym"
set -euo pipefail
```

Protects against:

* `oc login` failure → stop
* Missing variables → stop
* CSV read issues → stop
* Pipeline errors → stop


### Interview explanation:

> “I used `set -euo pipefail` to make the automation more reliable. It ensures the script exits on command failures, prevents execution with undefined variables, and catches failures inside piped commands to avoid partial or inconsistent operations.”


`pipefail` is confusing initially because pipelines (`|`) behave unexpectedly.

Think of a pipeline:

```bash id="mx97w2"
command1 | command2
```

Normally Bash checks **only the last command's result**.


Example without `pipefail`:

```bash id="zq8y4u"
cat missing.txt | wc -l
```

What happens:

Step 1:

```bash id="mz7b3w"
cat missing.txt
```

Fails:

```text id="kx82af"
cat: missing.txt: No such file
```

Step 2:
`wc -l` still runs.

Output:

```text id="8qz9i5"
0
```

Pipeline exit status = **success**

Script thinks everything is okay ❌


Now enable:

```bash id="ptjlwm"
set -o pipefail
```

Run again:

```bash id="mbu5a5"
cat missing.txt | wc -l
```

Result:

```text id="4ef9d2"
cat: missing.txt: No such file
```

Pipeline becomes **failed** ✅

Because one command inside pipeline failed.


Another example:

Without `pipefail`:

```bash id="mq7d4z"
false | true

echo $?
```

Output:

```text id="sj8mbg"
0
```

Why?

Because last command (`true`) succeeded.


With `pipefail`:

```bash id="ylwbq9"
set -o pipefail

false | true

echo $?
```

Output:

```text id="73rpkv"
1
```

Because first command failed.


Relate to your script:

```bash id="v92wrm"
tail -n +2 "$CSV_FILE" | while read ...
```

Without `pipefail`:

If:

```bash id="j10p50"
tail "$CSV_FILE"
```

fails,

the `while` loop may still run and script may continue silently.

With `pipefail`:

Entire pipeline fails immediately.


One-line interview explanation:

> “`pipefail` ensures that if any command in a pipeline fails, the whole pipeline is marked as failed instead of checking only the last command.”


---

11. What is trap command in linux ?

`trap` in shell scripting is used to **catch signals/events and execute a command or function automatically**.

Think of it like:

> “If something happens (CTRL+C, script exit, termination), run this cleanup code.”

Syntax:

```bash id="d0mqh9"
trap 'command' SIGNAL
```

or

```bash id="w8w3su"
trap function_name SIGNAL
```


## Example 1 — Catch CTRL+C

Script:

```bash id="xx4l5o"
#!/bin/bash

cleanup() {
    echo "Cleaning temporary files..."
}

trap cleanup INT

echo "Running..."

while true
do
sleep 1
done
```

Run:

```bash id="j68f7n"
./test.sh
```

Press:

```text id="syv54n"
CTRL+C
```

Output:

```text id="ymh8yq"
Cleaning temporary files...
```

Without `trap`:

Script simply stops.


## Example 2 — Auto delete temp file

```bash id="fzb40g"
#!/bin/bash

touch temp.txt

trap "rm -f temp.txt" EXIT

echo "Processing..."
```

After script exits:

```text id="1jw95e"
temp.txt deleted
```


## Your namespace deletion script

You had:

```bash id="e3v6mp"
trap cleanup_branch INT TERM
```

and:

```bash id="6jlwmw"
cleanup_branch() {

git checkout master

git branch -D "$branch_name"

git reset --hard origin/master
}
```

Meaning:

If user:

```text id="hzjlwm"
CTRL+C
```

or process gets terminated:

Execute:

```text id="h7bz0r"
Switch to master
Delete temporary branch
Restore repo state
```

This prevents half-completed Git changes.


## Common trap signals

| Signal | Meaning            |
| ------ | ------------------ |
| INT    | Interrupt (CTRL+C) |
| TERM   | Terminate          |
| EXIT   | Script exits       |
| HUP    | Terminal closed    |
| ERR    | Command failure    |

Examples:

### Run on exit

```bash id="2ixkga"
trap cleanup EXIT
```


### Run on command failure

```bash id="jjlwmr"
trap cleanup ERR
```


### Run on CTRL+C

```bash id="3vugjv"
trap cleanup INT
```

# Real DevOps use cases

### Cleanup temp files

```bash id="0i8vxv"
trap 'rm -rf /tmp/build' EXIT
```


### Rollback deployment

```bash id="1m7qil"
trap rollback ERR
```


### Logout cluster automatically

```bash id="p0j57q"
trap "oc logout" EXIT
```


### Interview explanation

> `trap` is used in shell scripting to capture signals such as interruption, termination, or script exit and execute cleanup or rollback logic. In my project, I used `trap` to automatically restore the Git repository state and delete temporary branches if the script was interrupted.`



---
