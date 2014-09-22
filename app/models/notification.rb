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
    return 100 if last_five_status.include?('DOWN')
    return 90 if last_five_status.include?('CRITICAL')
    return self.get_warning(last_five_status)
  end

  def self.get_warning(last_five_status)
    status = last_five_status.count('WARNING')
    case status
      when 5
        75
      when 4
        70
      when 3
        65
      when 2
        60
      when 1
        50
      else
        10
    end
  end

  def self.get_aggregate
    aggregate = Notification.collection.aggregate({ "$group" => {
        "_id" => {
            "nagios_hostname" => "$nagios_hostname",
            "nagios_state" => "$nagios_state",
            "nagios_service" => "$nagios_service",
            "nagios_epoch" => "$nagios_epoch"
        },
        "stateCount" => { "$sum" => 1 }
    }},
                                      { "$group" => {
                                          "_id" => "$_id.nagios_hostname",
                                          "notifications" => {
                                              "$push" => {
                                                  "state" =>  "$_id.nagios_state",
                                                  "count" => "$stateCount",
                                                  "service" =>  "$_id.nagios_service",
                                                  "date" => "$_id.nagios_epoch"
                                              },
                                          }
                                      }})
    return aggregate
  end

end