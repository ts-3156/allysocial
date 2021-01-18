module ApplicationHelper
  def show_desktop_site?
    params[:desktop_site] == 'true'
  end
end
