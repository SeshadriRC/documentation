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
