# frozen_string_literal: true

require_relative "jekyll_include_plugin/version"
require_relative "jekyll_include_plugin/utils"
require_relative "jekyll_include_plugin/jekyll_include_plugin"

Liquid::Template.register_tag("include_file", JekyllIncludePlugin::IncludeFileTag)
