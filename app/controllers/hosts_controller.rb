class HostsController < ApplicationController
  def index
    @hosts = Notification.distinct(:nagios_hostname)
  end
end
