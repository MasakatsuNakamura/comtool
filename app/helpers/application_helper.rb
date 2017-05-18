module ApplicationHelper

  # ページごとの完全なタイトルを返します。
  def full_title(page_title = '')
    base_title = "QINeS AUTOSAR Process Tools"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def embedded_svg filename, options={}
    file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    svg['class'] = options[:class] if options[:class].present?
    doc.to_html.html_safe
  end
end
