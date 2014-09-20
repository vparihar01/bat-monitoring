class HostsController < ApplicationController
  before_action :authenticate_user!
  def index
    @hosts = Notification.distinct(:nagios_hostname)
  end
end
