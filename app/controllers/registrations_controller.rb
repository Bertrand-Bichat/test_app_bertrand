class RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(resource)
    stored_location_for(resource) || root_path
  end

  # no need of password to update user info
  # def update_resource(resource, params)
  #   resource.update_without_password(params)

  #   # Require current password if user is trying to change password.
  #   # return super if params["password"]&.present?

  #   # Allows user to update registration information without password.
  #   # resource.update_without_password(params.except("current_password"))
  # end
end
