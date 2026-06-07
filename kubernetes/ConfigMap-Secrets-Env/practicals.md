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


- Now mount the configMap in pod using envfrom method.

[refer-yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/ConfigMap-Secrets-Env/deploy-config.yml)

<img width="1737" height="886" alt="image" src="https://github.com/user-attachments/assets/42ba5c82-0549-44ed-9527-8794341020f4" />

- Now login to the pod

<img width="881" height="797" alt="image" src="https://github.com/user-attachments/assets/5822fcb5-4b8a-4cbe-9b85-be893cfa317c" />
<img width="748" height="407" alt="image" src="https://github.com/user-attachments/assets/3f4403c7-9b06-4cf3-8583-cd60e97efbf8" />
<img width="538" height="190" alt="image" src="https://github.com/user-attachments/assets/8cdc2129-caeb-4d74-8079-139cb6c74db7" />

