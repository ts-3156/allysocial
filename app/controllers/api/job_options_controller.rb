module Api
  class JobOptionsController < BaseController
    before_action :authenticate_user!

    def index
      labels = Searchable::JOB_LABELS[I18n.locale]
      options = Searchable::JOB_QUERIES.map do |value|
        { value: strip_tags(value), label: labels[value.to_sym] }
      end

      render json: { options: options }
    end
  end
end
