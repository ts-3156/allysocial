class String
  def truncate_2bytes(truncate_at, omission: '...')
    if size == bytesize
      truncate(truncate_at, omission: omission)
    else
      size.times do |i|
        return (self[0..i] + omission) if self[0..i].each_char.sum { |c| c.bytesize == 1 ? 1 : 2 } > (truncate_at - omission.size)
      end
      self
    end
  end
end
