module ApplicationHelper
  def title(page_title)
    content_for(:title, page_title)
    return page_title
  end

  def navbar_element(name, link, extra_class = '')
    if current_page? link
      link_to(name, '#', class: "nav-item nav-link active #{extra_class}")
    else
      link_to(name, link, class: "nav-item nav-link #{extra_class}")
    end
  end
end
