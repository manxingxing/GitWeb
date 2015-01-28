module ReposHelper
  def file_icon entry
    class_names = ['octicon']

    case entry[:type]
    when :blob
      class_names << 'octicon-file-text'
    when :tree
      class_names << 'octicon-file-directory'
    end

    content_tag :span, nil, class: class_names.join(' ')
  end

  def file_link entry
    path = case entry[:type]
      when :blob
        repo_blob_path(repo: params[:repo], ref: params[:ref], path: [params[:path], entry[:name]].compact.join('/'))
      when :tree
        repo_tree_path(repo: params[:repo], ref: params[:ref], path: [params[:path], entry[:name]].compact.join('/'))
    end
    link_to entry[:name], path
  end

  def render_path_breadcumb
    parts = (params[:path] || '').split('/')
    html = parts.map.with_index do |entry, index|
      separator = content_tag(:span, '/', class: 'separator')
      link = content_tag :span do
        link_to entry, repo_tree_path(repo: params[:repo], ref: params[:ref], path: parts.take(index + 1))
      end
      separator + link
    end.join('').html_safe
  end
end
