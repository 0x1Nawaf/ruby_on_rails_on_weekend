class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
  end

  def user_home
    @blobs = BlobTrackingInfo.where(user_id: current_user.id)
  end
end
