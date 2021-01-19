require 'active_support/concern'

module Completable
  extend ActiveSupport::Concern

  def data_completed?
    completed_at.present?
  end
end
