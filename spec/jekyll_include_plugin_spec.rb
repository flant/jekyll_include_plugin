# frozen_string_literal: true
require "jekyll"
require "liquid"

RSpec.describe JekyllIncludePlugin do
  let(:dummy_site) do
    double(
      "site",
      config: { "jekyll_include_plugin" => { "snippet_prefix" => "..." }, "source" => __dir__ },
      file_read_opts: {}
    )
  end
  let(:dummy_registers) { { site: dummy_site, page: { "lang" => "en" } } }
  let(:dummy_context) { Liquid::Context.new({}, {}, dummy_registers) }

  let(:dummy_tokens) do
    arr = []
    def arr.line_number; 1; end
    arr
  end

  let(:raw_markup) { 'dummy.md snippet="example"' }
  let(:tag) do
    JekyllIncludePlugin::IncludeFileTag.send(:new, "include_file", raw_markup, dummy_tokens)
  end

  it "has a version number" do
    expect(JekyllIncludePlugin::VERSION).not_to be nil
  end

  describe "#render" do
    context "when snippet markers are correct" do
      let(:text) do
        <<~TEXT
          Some intro text
          [<snippet example>]
          line1
          line2
          [<endsnippet example>]
          Some other text
        TEXT
      end

      it "returns the snippet content" do
        allow(tag).to receive(:get_raw_file_contents).and_return(text)
        expect(tag.render(dummy_context)).to eq("...\nline1\nline2")
      end
    end

    describe "error handling" do
      before do
        allow(Jekyll.logger).to receive(:abort_with) do |prefix, msg|
          raise SystemExit, "#{prefix} #{msg}"
        end
      end

      context "when the snippet start marker is missing" do
        let(:text) do
          <<~TEXT
            Some intro text
            line1
            [<endsnippet example>]
            Some other text
          TEXT
        end

        it "aborts with a snippet not found error" do
          allow(tag).to receive(:get_raw_file_contents).and_return(text)
          expect { tag.render(dummy_context) }.to raise_error(SystemExit)
        end
      end

      context "when the snippet end marker is missing" do
        let(:text) do
          <<~TEXT
            Some intro text
            [<snippet example>]
            line1
            line2
            Some other text
          TEXT
        end

        it "aborts with an end marker not found error" do
          allow(tag).to receive(:get_raw_file_contents).and_return(text)
          expect { tag.render(dummy_context) }.to raise_error(SystemExit)
        end
      end

      context "when snippet content is empty" do
        let(:text) do
          <<~TEXT
            [<snippet example>]
            [<endsnippet example>]
          TEXT
        end

        it "aborts because the snippet content appears empty" do
          allow(tag).to receive(:get_raw_file_contents).and_return(text)
          expect { tag.render(dummy_context) }.to raise_error(SystemExit)
        end
      end

      context "when the snippet appears twice" do
        let(:text) do
          <<~TEXT
            [<snippet example>]
            line1
            [<snippet example>]
            line2
            [<endsnippet example>]
          TEXT
        end

        it "aborts because the snippet occurs twice" do
          allow(tag).to receive(:get_raw_file_contents).and_return(text)
          expect { tag.render(dummy_context) }.to raise_error(SystemExit)
        end
      end
    end

    context "when snippet_prefix is empty" do
      let(:dummy_site) do
        double(
          "site",
          config: { "jekyll_include_plugin" => { "snippet_prefix" => "" }, "source" => __dir__ }
        )
      end

      let(:text) do
        <<~TEXT
          Some intro text
          [<snippet example>]
          line1
          line2
          [<endsnippet example>]
          Some other text
        TEXT
      end

      it "returns the snippet content" do
        allow(tag).to receive(:get_raw_file_contents).and_return(text)
        expect(tag.render(dummy_context)).to eq("line1\nline2")
      end
    end

    context "with ignore markers and full file include" do
      let(:text) do
        <<~TEXT
          line before
          // [<ignore>]
          line to ignore 1
          line to ignore 2
          // [<endignore>]
          line after
        TEXT
      end

      let(:raw_markup) { 'dummy.md' }

      it "removes the ignore markers and all lines between them" do
        allow(tag).to receive(:get_raw_file_contents).and_return(text)
        expect(tag.render(dummy_context)).to eq("line before\nline after")
      end
    end

    context "with ignore markers and a snippet include" do
      let(:text) do
        <<~TEXT
          line before
          // [<snippet example>]
          line 1
          // [<ignore>]
          line to ignore 1
          line to ignore 2
          // [<endignore>]
          line 2
          // [<endsnippet example>]
          line after
        TEXT
      end

      it "removes the ignore markers and all lines between them" do
        allow(tag).to receive(:get_raw_file_contents).and_return(text)
        expect(tag.render(dummy_context)).to eq("...\nline 1\nline 2")
      end
    end
  end
end
