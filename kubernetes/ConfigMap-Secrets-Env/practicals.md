- here we are using same deployment yaml as we used in the **Deployment** topic.
- we can notice here it showing Default title.
<img width="1601" height="847" alt="image" src="https://github.com/user-attachments/assets/60d02794-6497-4321-845f-78b8ef4a570a" />
- As per [code](https://github.com/SeshadriRC/Simplybyte_calculator/blob/main/server.js#L6), if we pass env.PAGE_TITLE then it should show the passed value, otherwise it should show the Default Title.
- so now using configMap , we will give different name to the PAGE_TITLE.

```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: simplybyte-configmap
data:
  PAGE_TITLE: "Title from ConfigMap"
```
<img width="720" height="596" alt="image" src="https://github.com/user-attachments/assets/b00af82c-30f7-43fc-8101-b7445344aa21" />


## mount the configmap using envFrom

[refer-yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/ConfigMap-Secrets-Env/deploy-config.yml)

<img width="1737" height="886" alt="image" src="https://github.com/user-attachments/assets/42ba5c82-0549-44ed-9527-8794341020f4" />

- Now login to the pod

<img width="881" height="797" alt="image" src="https://github.com/user-attachments/assets/5822fcb5-4b8a-4cbe-9b85-be893cfa317c" />
<img width="748" height="407" alt="image" src="https://github.com/user-attachments/assets/3f4403c7-9b06-4cf3-8583-cd60e97efbf8" />
<img width="538" height="190" alt="image" src="https://github.com/user-attachments/assets/8cdc2129-caeb-4d74-8079-139cb6c74db7" />

## ConfigMap as a volumemounts

[yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/ConfigMap-Secrets-Env/deploy-config-volumemount.yml)

- it didn't display the latest value
<img width="1650" height="513" alt="image" src="https://github.com/user-attachments/assets/253cbe04-d548-435d-a022-b0a26a6f491d" />

- Also below it created a file for PAGE_TITLE. so as we said before if we use env variable in configmap then envfrom is the best option. This volumemount option is best suited if incase we created configmap as file.

<img width="893" height="312" alt="image" src="https://github.com/user-attachments/assets/ae040163-25b4-463b-97df-52b3d65ced79" />

## ConfigMap as a file

<img width="1037" height="668" alt="image" src="https://github.com/user-attachments/assets/91fc417a-f53b-44f5-bf4b-d39ac02c236e" />

