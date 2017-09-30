module ApplicationHelper
  def title(page_title)
    content_for(:title, page_title)
    return page_title
  end

  def navbar_element(name, link)
    if current_page? link
      ('<li class="active">' + link_to(name, '#') + '</li>').html_safe
    else
      ('<li>' + link_to(name, link) + '</li>').html_safe
    end
  end
end
