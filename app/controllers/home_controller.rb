class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @hosts_status = Notification.get_notifications(nil)
    # render :json => @hosts_status
  end
end
