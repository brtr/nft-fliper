module ApplicationHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def is_admin?
    admin_ids = ENV.fetch("ADMIN_IDS"){""}.split(',')
    current_user && current_user.id.to_s.in?(admin_ids)
  end

  def address_format(address)
    address = address.dup
    address[4...-4] = "...."
    address
  end

  def decimal_format(data)
    data.to_f.round(3)
  end

  def sort_arrow(sort_by)
    up_arrow = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevrons-up align-middle me-2"><polyline points="17 11 12 6 7 11"></polyline><polyline points="17 18 12 13 7 18"></polyline></svg>'
    down_arrow = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevrons-down align-middle me-2"><polyline points="7 13 12 18 17 13"></polyline><polyline points="7 6 12 11 17 6"></polyline></svg>'
    if params[:sort] == "desc" && params[:sort_by] == sort_by
      up_arrow.html_safe
    elsif params[:sort] == "asc" && params[:sort_by] == sort_by
      down_arrow.html_safe
    else
    end
  end

  def time_format(datetime)
    datetime.strftime("%Y-%m-%d %H:%M") rescue ''
  end

  def date_format(datetime)
    datetime.strftime("%Y-%m-%d") rescue ''
  end

  def humanize_gap(gap)
    gap = gap.to_f
    if gap < 86400
      hours = gap / 3600
      "#{I18n.t('duration.hours', count: hours.round(2))}"
    else
      days = (gap / 86400).to_i
      hours = (gap - days * 86400) / 3600
      "#{I18n.t('duration.days', count: days)}"
    end
  end

  def display_price(coin, price, usd)
    if usd != 0
      "#{decimal_format price} #{coin} ($#{decimal_format usd})"
    else
      "#{decimal_format price} #{coin}"
    end
  end
end
