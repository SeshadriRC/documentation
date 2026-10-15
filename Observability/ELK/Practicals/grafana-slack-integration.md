
# Create App in slack

Create a custom Slack app for your workspace
This can seem like a daunting task, but it's actually pretty simple, and it requires minimal configuration to connect to Grafana.

As part of app setup youll be asked to select a slack channel to associate with the app. If you would like your Grafana alerts to go to a new
channel, create that before proceeding.

1. Create a channel in grafana and Go to https://api.slack.com/apps and click Create an App.

2. In the Create an app modal, choose From scratch.

3. Name your app and select your workspace. Click Create App. --> select next .. next and create it

4. Select the Incoming Webhooks option from the Add features and functionality menu.

5. Toggle on webhooks.

6. Click Add New Webhook to Workspace at the bottom of the Webhook URLs for your Workspace section.

7. Select the Slack channel you would like to connect the app to and click Allow.

8. The page will refresh and you will see a webhook URL in the Webhook URLs for your Workspace section. You can click Copy now, 


<img width="1743" height="521" alt="image" src="https://github.com/user-attachments/assets/03d2034b-4d4c-401c-992a-fff482b5a595" />

<img width="1917" height="861" alt="image" src="https://github.com/user-attachments/assets/00695fd6-641b-4aec-bc56-8afd3dcd7090" />

<img width="938" height="742" alt="image" src="https://github.com/user-attachments/assets/a621135b-8193-4c9e-a77e-8cdba5841c42" />

<img width="903" height="597" alt="image" src="https://github.com/user-attachments/assets/f9f2f697-f720-435a-b169-dc833723d3e0" />

<img width="1917" height="818" alt="image" src="https://github.com/user-attachments/assets/d2cdc883-c093-4573-9421-35b06b3bc8d9" />

<img width="1917" height="802" alt="image" src="https://github.com/user-attachments/assets/f845fbd8-2947-496f-bc6f-e1458029d38d" />

<img width="1907" height="740" alt="image" src="https://github.com/user-attachments/assets/b52b713e-2872-4614-8984-693689ff2136" />

<img width="1591" height="578" alt="image" src="https://github.com/user-attachments/assets/c6f1935c-13be-44ea-adf2-5b510bdb3f74" />

---

# Integrate with Grafana

1. Hamburger menu --> Alerting --> Notification configuration
2. Click new contact point 
3. Enter a contact point name
4. From the integration list select slack
5. We are using webhook URL, hence copy and paste it
6. Now test the alert and save the contact point, then check the slack channel. You will be getting a test alert


<img width="1917" height="717" alt="image" src="https://github.com/user-attachments/assets/97af6655-7516-4b06-bc75-333e8b8bf74e" />

<img width="1917" height="872" alt="image" src="https://github.com/user-attachments/assets/335b40e4-3c0e-4f4f-98da-21c5f1d9e2eb" />

<img width="1917" height="846" alt="image" src="https://github.com/user-attachments/assets/28032e49-7f5b-4ad3-8f52-d804ed4a21fa" />

<img width="1917" height="787" alt="image" src="https://github.com/user-attachments/assets/bd7404e4-6e94-46d8-93eb-84011082c461" />
