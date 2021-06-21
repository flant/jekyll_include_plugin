# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require_relative "lib/jekyll_include_plugin/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll_include_plugin"
  spec.version       = JekyllIncludePlugin::VERSION
  spec.authors       = ["Ilya Lesikov"]
  spec.email         = ["ilya@lesikov.com"]

  spec.summary       = "Include files or file samples into Markdown, allows for multilang comments in included files."
  spec.homepage      = "https://github.com/flant/jekyll_include_plugin"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/flant/jekyll_include_plugin"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "liquid", "~> 4.0"
  spec.add_runtime_dependency "jekyll", "~> 3.9"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  # spec.add_development_dependency "rubocop", "~> 1.7"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
