module ApplicationHelper
  def title title_content
    provide(:title) { title_content }
  end
end
