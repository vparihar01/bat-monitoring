json.array!(@notifications) do |notification|
  json.extract! notification, :id, :nagios_type, :nagios_hostname, :nagios_service, :nagios_state, :nagios_statelevel, :nagios_attempt, :nagios_message
  json.url notification_url(notification, format: :json)
end
