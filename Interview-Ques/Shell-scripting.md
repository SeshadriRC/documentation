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
