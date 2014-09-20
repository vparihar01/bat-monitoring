class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  ## Database authenticatable
  field :nagios_type, type: String, default: ""
  field :nagios_hostname, type: String, default: ""
  field :nagios_service, type: String, default: ""
  field :nagios_state, type: String, default: ""
  field :nagios_statelevel, type: String, default: ""
  field :nagios_attempt, type: String, default: ""
  field :nagios_message, type: String, default: ""
end

