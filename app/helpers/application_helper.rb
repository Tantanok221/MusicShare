module ApplicationHelper
  def admin_user?
    user_signed_in? && current_user.admin?
  end
end
