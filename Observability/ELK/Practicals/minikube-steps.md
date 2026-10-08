## High level steps

Kibana
-------
Observability --> Alerts --> Manage rules --> create rule --> metric threshold 

name: slack alert
select conditions

```
IF

kubernetes.pod.name = any pod
AND
log.level = ERROR

AND

ERROR count > 10
within 5 minutes

THEN

Send Slack alert
```

Slack
-----
Create a private slack channel 

Add apps --> manage --> incoming webhook --> Add to slack --> choose a channel --> Add incoming webhook integratios --> copy the webhook URL


Kibana
------
Stack management --> Connectors --> Create your first connector --> Select a slack as a connector

```
Connector name: Slack Alert connector
Connector settings: webhook URL
Save and test 
create an action --> run the test --> check the slack
```

Alerts --> manage rules --> click slack alert --> Actions --> edit rule --> connector type --> slack --> save it
