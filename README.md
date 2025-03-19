# Jekyll Include Plugin

Include contents of local/remote plain text files (or parts of them) into your pages.
Allows multilang comments in the included files, which language will be used depends on `{{ page.lang }}`.

## Usage

Basic usage as follows:

```jinja
/jekyllroot/pages/foo.md:
-----------------------
lang: en
-----------------------
{% include_file "foo/Dockerfile" snippet="system_deps" syntax="Dockerfile" %}
```

```Dockerfile
/jekyllroot/foo/Dockerfile:
--------------------------------------------------------
FROM ruby

# [<snippet system_deps>]
# [<en>] Install system dependencies
# [<en>] (multiline possible too)
# [<ru>] Установка системных зависимостей
RUN apt update && apt install curl -y
# [<endsnippet system_deps>]
```

Result:
```Dockerfile
# Install system dependencies
# (multiline possible too)
RUN apt update && apt install curl -y
```

Include the local file (path is relative to Jekyll root):
```jinja
{% include_file "Dockerfile" %}
```

Include the remote file (only absolute urls):
```jinja
{% include_file "https://raw.githubusercontent.com/werf/werf-guides/master/examples/rails/010_build/Dockerfile" %}
```

Include part of the file (the part should be enclosed in `[<snippet snippetname>]` and `[<endsnippet snippetname>]`):
```jinja
{% include_file "Dockerfile" snippet="snippetname" %}
```

Include the file and wrap the result in `` ```dockerfile `` and `` ``` ``:
```jinja
{% include_file "Dockerfile" syntax="dockerfile" %}
```

Dynamic parameters:
```jinja
{% include_file "{{ $templatingAllowedHere }}/Dockerfile" snippet="{{ $hereToo }}" %}
```

## Ignore a part of an included content

The usage:
```jsx
const template = () => {
  return (
    // [<snippet example>]
    <Provider
      // [<ignore>]
      propToIgnore={propToIgnore}
      // [<endignore>]
      component={() => <div>Data is loading...</div>}
      errorComponent={({ message }) => <div>There was an error: {message}</div>}
    >
      ...
    </Provider>
    // [<endsnippet example>]
  );
};
```

The result:
```jsx
  <Provider
    component={() => <div>Data is loading...</div>}
    errorComponent={({ message }) => <div>There was an error: {message}</div>}
  >
    ...
  </Provider>
```

## Plugin options in `_config.yml`

Default options:
```yml
jekyll_include_plugin:
  snippet_prefix: '...'
```

### `snippet_prefix`
Type: `string` Default: `...`

Prepends the prefix at the end of included snippet to differentiate whole file includes vs partial file includes (snippet)  

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
