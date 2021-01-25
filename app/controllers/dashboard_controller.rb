class DashboardController < ApplicationController
  before_action :authenticate_user
  before_action :must_be_completed

  def index
    @initial_label = fetch_initial_label
  end

  private

  def must_be_completed
    redirect_to waiting_path unless current_user.user_snapshot&.data_completed?
  end

  def fetch_initial_label
    begin
      value = current_user.user_snapshot.friends_insight.job['words_count'].first.first
      JobSelector.value_to_label(value)
    rescue => e
      current_user.to_user_decorator(view_context).job_label_s
    end
  rescue => e
    ''
  end
end
