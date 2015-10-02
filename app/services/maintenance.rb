class Maintenance
  def self.enabled?
    ENV['MAINTENANCE'] == 'TRUE'
  end

  def self.disabled?
    !enabled?
  end
end
