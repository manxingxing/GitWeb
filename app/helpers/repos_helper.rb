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
    paths = (params[:path] || '').split('/')
    final_path = paths.pop

    links = []

    repo_name = content_tag :span, class: 'repo-root' do
      link_to params[:repo], repo_tree_path(repo: params[:repo], ref: params[:ref])
    end

    links.push repo_name

    paths.each_with_index do |path, index|
      path_link = content_tag :span do
        link_to path, repo_tree_path(repo: params[:repo], ref: params[:ref], path: paths.take(index + 1) )
      end
      links.push path_link
    end

    if final_path
      links.push(content_tag(:strong, final_path, class: 'final-path'))
    end
    links.join("<span class='separator'>/</span>").html_safe
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
      new_path
    when :deleted, :ignored, :untracked
      old_path
    when :renamed
      abbr_path_change(old_path, new_path, " &rarr; ")
    when :copied
      abbr_path_change(old_path, new_path, " &rArr; ")
    end
  end

  def highlight_code code, language
    options = {:nowrap => 'False', linenos: 'table'}
    if Pygments::Lexer.find(language)
      Pygments.highlight(code, :lexer => language, options: options)
    else
      Pygments.highlight(code, :lexer => "text", options: options)
    end
  end

private
  def abbr_path_change old_path, new_path, separator = " &rarr; "
    old_path_segments = old_path.split('/')
    new_path_segments = new_path.split('/')

    uncommonIdx = old_path_segments.zip(new_path_segments).index {|old, new| old != new } || 0

    if uncommonIdx == 0
      [old_path, new_path].join(separator).html_safe
    else
      path_change = [old_path_segments.drop(uncommonIdx).join('/'), new_path_segments.drop(uncommonIdx).join('/')].join(separator)
      [old_path_segments.take(uncommonIdx).join('/'), "{#{path_change}}"].join('/').html_safe
    end
  end
end
