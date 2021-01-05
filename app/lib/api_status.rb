class ApiStatus
  def initialize(attrs)
    @attrs = attrs
  end

  def user_uid
    @attrs.dig(:user, :id)
  end

  def created_at
    if @attrs[:created_at]
      Time.zone.parse(@attrs[:created_at])
    end
  end
end
