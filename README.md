# Jekyll Include Plugin

## Usage

Basic usage as follows:

```jinja
jekyllroot/pages/foo.md:
-----------------------
lang: en
-----------------------
{% include_file "this_dir_is_inside_jekyll_root_dir/foo/Dockerfile" snippet="system_deps" syntax="Dockerfile" %}
```

```Dockerfile
this_dir_is_inside_jekyll_root_dir/foo/Dockerfile:
--------------------------------------------------------
FROM ruby

# [<snippet install_system_deps>]
# [<en>] Install system dependencies
# [<en>] (multiline possible too)
# [<ru>] Установка системных зависимостей
RUN apt update && apt install curl -y
# [<endsnippet install_system_deps>]
```

Result:
```Dockerfile
# Install system dependencies
# (multiline possible too)
RUN apt update && apt install curl -y
```

Include whole file:
```jinja
{% include_file "Dockerfile" %}
```

Include remote file:
```jinja
{% include_file "https://raw.githubusercontent.com/werf/werf-guides/master/examples/rails/010_build/Dockerfile" %}
```

Dynamic parameters:
```jinja
{% include_file "{{ $templatingAllowedHere }}" snippet="{{ $hereToo }}" %}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll_include_plugin'
```

And this into your Jekyll config:
```yaml
plugins:
  - jekyll_include_plugin
```

Then execute:
```bash
bundle install
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
