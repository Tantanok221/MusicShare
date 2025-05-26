class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def ensure_admin
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
