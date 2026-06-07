**1. What is (-) in below spec container section?**

- It denotes the list, if we want to specify multiple items then we can use. for example there can be multiple containers under the container section
- one container will throw the error, as containerport is wrong.
```yml
apiVersion: v1
kind: Pod

metadata:
  name: my-simplybyte-calculator-pod-2
  labels:
    project: calculator

spec:
  containers:
  - name: simply-byte-calculator-1
    image: simplebyte/simplybyte-calculator
    ports:
    - containerPort: 5000

  - name: simply-byte-calculator-2
    image: simplebyte/simplybyte-calculator
    ports:
    - containerPort: 2000
```
