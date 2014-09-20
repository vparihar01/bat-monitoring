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
  field :nagios_epoch, type: String, default: ""

  attr_accessor :nagios_epoch

  def nagios_epoch
    # custom actions
    ###
    Time.at(super.to_i)
    # this is same as self[:attribute_name] = value
  end

  def self.get_notifications(current_user)
    #todo will filter the notifications for current user
    notifications = Notification.all.to_a
    notifications_details =[]
    notifications =notifications.group_by{|i| i.nagios_hostname}
    hosts = notifications.keys
    notifications.each do |key, value|
     notifications_details.push({key => get_aggregate_data(key, notifications)})
    end
    notifications_details
  end

  def self.get_aggregate_data(key, notifications)
    data = notifications[key]
    data.each do |i|
      puts i.class
      i[:time_of_notification] = i.nagios_epoch
    end
    crash_and_warn = data.select{|i| i.nagios_state == 'WARNING' || i.nagios_state == 'DOWN' || i.nagios_state == 'CRITICAL' }
    crash_and_warn= crash_and_warn.sort{|i,j| j.time_of_notification <=> i.time_of_notification}.first(5).collect{|i| {time: i.time_of_notification, status: i.nagios_state}}
    mail_sent_at = data.select{|i| i.nagios_statelevel == 'HARD'}.sort{|i,j| j.time_of_notification <=> i.time_of_notification}.first(5).collect{|i| i.time_of_notification}
    last_five_status = data.sort{|i,j| j.time_of_notification <=> i.time_of_notification}.first(5).collect{|i| i.nagios_state}
    status = get_status(last_five_status)
    {crash_and_warn: crash_and_warn, mail_sent_at: mail_sent_at, status: status}

  end

  def self.get_status(last_five_status)
    return 'DOWN' if last_five_status.include?('DOWN')
    return 'CRITICAL' if last_five_status.include?('CRITICAL')
    return 'WARNING' if last_five_status.include?('WARNING')
    return 'UP' if last_five_status.include?('UP')
    return 'STABLE' if last_five_status.include?('OK')
  end


end