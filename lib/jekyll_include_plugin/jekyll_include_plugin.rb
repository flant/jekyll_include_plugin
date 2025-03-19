# TODO: don't read the whole file into the memory from the beginning, instead process file with the parser line by line
require "open-uri"
require "liquid"

module JekyllIncludePlugin
  class IncludeFileTag < Liquid::Tag
    include Utils
    include TextUtils

    def initialize(tag_name, raw_markup, tokens)
      super
      @raw_markup = raw_markup
      @config = {}
      @params = {}
    end

    def render(context)
      read_config(context)
      parse_params(context)

      file_contents = get_raw_file_contents(context)

      if @params["snippet"]
        file_contents = pick_snippet(file_contents, @config['snippet_prefix'], @params["snippet"])
      else
        file_contents = remove_all_snippets(file_contents)
      end

      file_contents = remove_ignored_lines(file_contents)
      file_contents = remove_excessive_newlines(file_contents)
      file_contents = remove_excessive_indentation(file_contents)
      file_contents = render_comments(file_contents, context.registers[:page]["lang"])
      file_contents = wrap_in_codeblock(file_contents, @params["syntax"]) if @params["syntax"]

      return file_contents
    end

    private

    def read_config(context)
      site = context.registers[:site]
      plugin_config = site.config["jekyll_include_plugin"] || {}

      @config["snippet_prefix"] = plugin_config['snippet_prefix'] || '...'
    end

    def parse_params(context)
      rendered_markup = Liquid::Template
        .parse(@raw_markup)
        .render(context)
        .gsub(%r!\\\{\\\{|\\\{\\%!, '\{\{' => "{{", '\{\%' => "{%")
        .strip
      debug("Rendered params: #{rendered_markup}")

      markup = %r!^"?(?<path>[^\s\"]+)"?(?<params>(\s+\w+="[^\"]+")*)?$!.match(rendered_markup)
      debug("Matched params: #{markup.inspect}")
      abort("Can't parse include_file tag params: #{@raw_markup}") unless markup

      if markup[:params]
        @params = Hash[ *markup[:params].scan(%r!(?<param>[^\s="]+)(?:="(?<value>[^"]+)")?\s?!).flatten ]
      end

      if %r!^https?://\S+$!.match?(markup[:path])
        @params["abs_file_url"] = markup[:path]
      else
        @params["rel_file_path"] = markup[:path]
      end

      validate_param_by_regex("snippet", "^[-_.a-zA-Z0-9]+$")
      validate_param_by_regex("syntax", "^[-_.a-zA-Z0-9]+$")

      debug("Params set: #{@params.inspect}")
    end

    def validate_param_by_regex(param_name, param_regex)
      if @params[param_name] && ! %r!#{param_regex}!.match?(@params[param_name])
        abort("Parameter '#{param_name}' with value '#{@params[param_name]}' is not valid, must match regex: #{param_regex}")
      end
    end

    def get_raw_file_contents(context)
      if @params["abs_file_url"]
        return get_remote_file_contents()
      elsif @params["rel_file_path"]
        return get_local_file_contents(context)
      end
      raise "Neither abs_file_url nor rel_file_path have been found"
    end

    def get_local_file_contents(context)
      base_source_dir = File.expand_path(context.registers[:site].config["source"]).freeze
      abs_file_path = File.join(base_source_dir, @params["rel_file_path"])

      begin
        debug("Getting contents of specified local file: #{abs_file_path}")
        return File.read(abs_file_path, **context.registers[:site].file_read_opts)
      rescue SystemCallError, IOError => e
        abort("Can't get the contents of specified local file '#{abs_file_path}': #{e.message}")
      end
    end

    def get_remote_file_contents()
      begin
        debug("Getting contents of specified remote file: #{@params["abs_file_url"]}")
        return URI.open(@params["abs_file_url"]).read
      rescue OpenURI::HTTPError => e
        abort("Can't get the contents of specified remote file '#{@params["abs_file_url"]}': #{e.message}")
      end
    end
  end
end
