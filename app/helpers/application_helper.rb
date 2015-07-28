module ApplicationHelper
  def flash_class(name)
    case name.to_s
      when 'notice', 'success'
        'success'
      when 'warning'
        'warning'
      else
        'danger'
    end
  end
end
