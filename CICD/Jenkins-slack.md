[repo](https://github.com/SeshadriRC/3-Tier-DevSecOps-Mega-Project/blob/main/Jenkinsfile-slack_notifications)

- Follow the PDF first from the repo
- This method will work only with public channel 
- Make sure to install the slack plugin
- Manage Jenkins --> System --> Slack --> Enter the workspace
- Then in the same page --> Add creds --> Secret text
- Then select the channel name, then check mark the custom slack bot user and save it. Below is the creds of custom slack bot
- Create the pipeline and run it

<img width="1247" height="151" alt="image" src="https://github.com/user-attachments/assets/cd951b64-92b7-437f-9cb9-98124bd5f259" />

- Manage jenkins --> Creds --> Add creds --> Secret text --> Copy the webhook URL

<img width="1917" height="777" alt="image" src="https://github.com/user-attachments/assets/1fefaa3a-7107-4847-bcb3-44432ef6ad2d" />

---

<img width="1917" height="847" alt="image" src="https://github.com/user-attachments/assets/9454ada8-821d-453d-95fb-a3cbf5f27edc" />


<img width="1917" height="593" alt="image" src="https://github.com/user-attachments/assets/7330ba25-ca7f-475c-af70-92f0c8fbb75c" />

<img width="1000" height="597" alt="image" src="https://github.com/user-attachments/assets/9269b8c7-0a51-424a-b5a5-86cdc37bb4f0" />

<img width="1917" height="840" alt="image" src="https://github.com/user-attachments/assets/10606561-e22e-4e34-b101-ffbbe97d1cd2" />

<img width="1917" height="731" alt="image" src="https://github.com/user-attachments/assets/7dc258b3-1944-4031-86bd-2c301354c444" />

<img width="905" height="732" alt="image" src="https://github.com/user-attachments/assets/a4ac6b44-450a-45e2-8204-bbaaefa02892" />

<img width="1917" height="633" alt="image" src="https://github.com/user-attachments/assets/fbf3694b-20e1-400d-aa03-a612eabc534c" />

- After testing it will show like this
<img width="1712" height="306" alt="image" src="https://github.com/user-attachments/assets/0a59d34d-6df5-48b0-910a-059075679f71" />

---

- Below it showing success

<img width="1830" height="432" alt="image" src="https://github.com/user-attachments/assets/cc01f8cd-239f-4765-80c5-5321ac42dc6d" />

- Now change the code `mvn test` and test it, it should trigger failure

<img width="1907" height="678" alt="image" src="https://github.com/user-attachments/assets/dcabf5b9-a3b8-462b-9f2a-a7bd8638ed38" />
