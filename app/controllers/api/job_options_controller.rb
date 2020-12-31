module Api
  class JobOptionsController < BaseController
    before_action :authenticate_user!

    def index
      labels = JobSelector::LABELS[I18n.locale]
      options = JobSelector::VALUES.map do |value|
        { value: labels[value.to_sym], label: labels[value.to_sym] }
      end

      render json: { options: options }
    end
  end
end
