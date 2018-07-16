terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "pagerduty.tfstate"
  }
}

variable pagerduty_token {
  description = "The api token to authenticate with Pagerduty configured by setting the environment variable `TF_VAR_pagerduty_token`"
}

variable oncall_phonenumber {
  description = "The phone number of the oncall person, *note* drop the leading 0, configured by setting the environment variable `TF_VAR_oncall_phone`"
}

variable oncall_name {
  description = "The name of the oncall person configured by setting the environment variable `TF_VAR_oncall_name`"
}

variable oncall_email {
  description = "The team on call email configured by setting the environment variable `TF_VAR_oncall_email`"
}

provider "pagerduty" {
  token = "${var.pagerduty_token}"
}

resource "pagerduty_team" "re-tools-support" {
  name = "RE Tools Support"
}

resource "pagerduty_user" "oncall-user" {
  name        = "RE Tools Team"
  description = ""
  email       = "${var.oncall_email}"
  teams       = ["${pagerduty_team.re-tools-support.id}"]
}

resource "pagerduty_user_contact_method" "gmail-group" {
  user_id = "${pagerduty_user.oncall-user.id}"
  type    = "email_contact_method"
  address = "${var.oncall_email}"
  label   = "Google Group"
}

resource "pagerduty_user_contact_method" "oncall-phone" {
  user_id      = "${pagerduty_user.oncall-user.id}"
  type         = "phone_contact_method"
  country_code = "+44"
  address      = "${var.oncall_phonenumber}"
  label        = "${var.oncall_name}"
}

resource "pagerduty_escalation_policy" "production" {
  name  = "Re Tools Team Production"
  teams = ["${pagerduty_team.re-tools-support.id}"]

  rule {
    escalation_delay_in_minutes = 30

    target {
      type = "user_reference"
      id   = "${pagerduty_user.oncall-user.id}"
    }
  }
}

resource "pagerduty_service" "prometheus-service" {
  name = "RE Tools Team Prometheus"

  acknowledgement_timeout = "null"
  auto_resolve_timeout    = "null"

  alert_creation    = "create_alerts_and_incidents"
  escalation_policy = "${pagerduty_escalation_policy.production.id}"

  incident_urgency_rule {
    type = "use_support_hours"

    during_support_hours {
      type    = "constant"
      urgency = "high"
    }

    outside_support_hours {
      type    = "constant"
      urgency = "low"
    }
  }

  support_hours {
    type         = "fixed_time_per_day"
    time_zone    = "Europe/London"
    start_time   = "09:00:00"
    end_time     = "18:00:00"
    days_of_week = [1, 2, 3, 4, 5]
  }

  scheduled_actions {
    type       = "urgency_change"
    to_urgency = "high"

    at {
      type = "named_time"
      name = "support_hours_start"
    }
  }
}
