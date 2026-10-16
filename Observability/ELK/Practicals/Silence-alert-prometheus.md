You're on the correct Alertmanager → New Silence page. Fill it in like this to temporarily suppress all standard Prometheus alert notifications.

## Enter these values

Start

Select the current time (now).

Duration

`1h`

Silence for one hour.

Matchers

Add this custom matcher:

`alertname` `=~` `.+`

This matches alerts with any non-empty alert name.

Copy matcher

Creator

`DevOps Lab`

Copy

Comment

`Temporarily silencing all alerts during lab testing`

Copy

## About “Cannot display affected Alerts, Silence is not yet valid”

This can appear before the silence's start time. Make sure the Start is now or in the past, and the End is in the future. Then check whether the affected-alert preview updates.

Once all fields are filled, click Create.

Important: This suppresses notifications routed through Alertmanager. Prometheus continues evaluating rules, and notifications from separate Grafana alerting configurations may still be sent.
