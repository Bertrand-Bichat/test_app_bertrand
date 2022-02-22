class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # stock la page actuelle avant d'authentifier l'utilisateur afin de pouvoir revenir dessus après le login
  before_action :store_user_location!, if: :storable_location?
  before_action :configure_permitted_parameters, if: :devise_controller?

  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, except: [:index, :my_journeys_index], unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Raise an alert if not authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_to(root_path)
  end

  # vérifie que la page peut être stocker pour ne pas tomber dans une boucle de redirection infinie
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  # stock la page pour que l'utilisateur soit redirigé après le login
  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def default_url_options
    { host: ENV['DOMAIN'] || "localhost:3000" } # rajouter le nom de domaine en prod
  end

  # equivalent a user_params (qu'est-ce qu'on autorise a etre modifie)
  def configure_permitted_parameters
    # lors de la creation d'un nouveau compte
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(
        :email,
        :password,
        :password_confirmation
      )
    end

    # lors de la modification d'un compte deja existant
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(
        :email,
        :password,
        :password_confirmation,
        :current_password
      )
    end
  end
end
