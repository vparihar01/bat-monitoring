class HostsController < ApplicationController
  before_action :authenticate_user!
  def index
    @hosts = Notification.distinct(:nagios_hostname)
    @hosts_status = Notification.get_notifications(nil)
  end
end
