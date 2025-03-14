class SettingsController < ApplicationController
  before_action :get_user
  before_action :check_owner_permission

  def show
  end

  def update
    if params[:pagination]
      @user.pagination_settings["models"] = params[:pagination][:models] == "1"
      @user.pagination_settings["creators"] = params[:pagination][:creators] == "1"
      @user.pagination_settings["per_page"] = params[:pagination][:per_page].to_i
    end
    if current_user.admin? && params[:model_tags]
      SiteSettings.model_tags_filter_stop_words = params[:model_tags][:filter_stop_words] == "1"
      SiteSettings.model_tags_stop_words_locale = params[:model_tags][:stop_words_locale]
      SiteSettings.model_tags_custom_stop_words = params[:model_tags][:custom_stop_words].split
    end
    @user.save!
    redirect_to user_settings_path(@user)
  end

  private

  def get_user
    @user = User.find_by_username(params[:user_id])
  end

  def check_owner_permission
    render plain: "401 Unauthorized", status: :unauthorized unless @user == current_user || current_user.admin?
  end
end
