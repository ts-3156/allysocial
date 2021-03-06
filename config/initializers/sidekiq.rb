database = Rails.env.test? ? 1 : 0

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379/#{database}", namespace: "#{Rails.env}:AllySocial" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379/#{database}", namespace: "#{Rails.env}:AllySocial" }
end
