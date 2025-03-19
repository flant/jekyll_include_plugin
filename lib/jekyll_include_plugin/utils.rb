module JekyllIncludePlugin
  module Utils
    def debug(msg)
      Jekyll.logger.debug("[jekyll_include_plugin] DEBUG:", msg)
    end

    def info(msg)
      Jekyll.logger.info("[jekyll_include_plugin] INFO:", msg)
    end

    def abort(msg)
      Jekyll.logger.abort_with("[jekyll_include_plugin] FATAL:", msg)
    end
  end

  module TextUtils
    include Utils

    def pick_snippet(text, snippet_prefix, snippet_name)
      snippet_content = ""
      snippet_start_found = false
      snippet_end_found = false
      text.each_line do |line|
        if %r!\[<snippet\s+#{snippet_name}>\]!.match?(line)
          if snippet_start_found
            abort("Snippet '#{snippet_name}' occured twice. Each snippet should have a unique name, same name not allowed.")
          end
          snippet_start_found = true
          debug("Snippet '#{snippet_name}' start matched by line: #{line}")
        elsif %r!\[<endsnippet\s+#{snippet_name}>\]!.match?(line)
          snippet_end_found = true
          debug("Snippet '#{snippet_name}' end matched by line: #{line}")
          break
        elsif %r!\[<(end)?snippet\s+[^>]+>\]!.match?(line)
          debug("Skipping line with non-relevant (end)snippet: #{line}")
          next
        elsif snippet_start_found
          snippet_content += line
        end
      end
      abort("Snippet '#{snippet_name}' has not been found.") unless snippet_start_found
      abort("End of the snippet '#{snippet_name}' has not been found.") unless snippet_end_found
      abort("Snippet '#{snippet_name}' appears to be empty. Fix and retry.") if snippet_content.empty?

      return snippet_content if snippet_prefix.empty?

      first_line_indent = %r!^\s*!.match(snippet_content)[0]
      return "#{first_line_indent}#{snippet_prefix}\n#{snippet_content}"
    end

    def remove_ignored_lines(text)
      ignoring = false
      text.each_line.reject do |line|
        if line =~ /^\s*\/\/\s*\[<ignore>\]/
          ignoring = true
          true
        elsif line =~ /^\s*\/\/\s*\[<endignore>\]/
          ignoring = false
          true
        else
          ignoring
        end
      end.join
    end

    def remove_all_snippets(text)
      result_text = ""
      text.each_line do |line|
        if %r!\[<(end)?snippet\s+[^>]+>\]!.match?(line)
          debug("Skipping line with non-relevant (end)snippet: #{line}")
          next
        else
          result_text += line
        end
      end

      return result_text
    end

    def render_comments(text, lang)
      rendered_file_contents = ""
      text.each_line do |line|
        if %r!\[<#{lang}>\]!.match?(line)
          debug("Matched doc line: #{line}")
          rendered_file_contents += line.sub(/\[<#{lang}>\]\s*/, "")
        elsif %r!\[<\w+>\]!.match?(line)
          debug("Found non-matching doc line, skipping: #{line}")
          next
        else
          rendered_file_contents += line
        end
      end

      return rendered_file_contents
    end

    def remove_excessive_newlines(text)
      return text.sub(/^(\s*\R)*/, "").rstrip()
    end

    def remove_excessive_indentation(text)
      unindented_text = ""

      lowest_indent = nil
      text.each_line do |line|
        if %r!^\s*$!.match?(line)
          next
        else
          cur_indent = %r!^\s*!.match(line)[0].length
          lowest_indent = cur_indent if lowest_indent.nil? || lowest_indent > cur_indent
        end
      end
      return text if lowest_indent.nil?

      text.each_line do |line|
        if blank_line?(line)
          unindented_text += line
        else
          unindented_text += line[lowest_indent..-1]
        end
      end

      return unindented_text
    end

    def wrap_in_codeblock(text, syntax)
      return "```#{syntax}\n#{text}\n```"
    end

    def blank_line?(line)
      return %r!^\s*$!.match?(line)
    end
  end
end
