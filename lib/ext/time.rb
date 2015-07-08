class Time
  def to_unix
    self.strftime('%s').to_i * 1000
  end
end
