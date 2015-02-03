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

  def abbrev_sha shas, &block
    abbreviated_shas = []
    Rugged.minimize_oid(shas) do |oid|
      abbreviated_shas.push oid
    end

    abbreviated_shas.zip(shas).each do |short, oid|
      yield short, oid
    end
  end

  def format_filename delta
    new_path, old_path = delta.new_file[:path], delta.old_file[:path]
    case delta.status
    when :modified, :added, :typechange
      filename = new_path
    when :deleted, :ignored?, :untracked
      filename = old_path
    when :renamed, :copied?
      filename = "#{old_path} -> #{new_path}"
    end
    filename
  end

  def highlight_code code, language
    options = {:nowrap => 'False', linenos: 'table'}
    if Pygments::Lexer.find(language)
      Pygments.highlight(code, :lexer => language, options: options)
    else
      Pygments.highlight(code, :lexer => "text", options: options)
    end
  end
end
