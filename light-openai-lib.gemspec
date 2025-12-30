# frozen_string_literal: true

require_relative "lib/light/openai/version"

Gem::Specification.new do |spec|
  spec.name          = "light-openai-lib"
  spec.version       = Light::OpenAI::VERSION
  spec.authors       = ["Gaetan Juvin"]
  spec.email         = ["opensource@example.com"]

  spec.summary       = "Minimal OpenAI chat completions client with retry logic"
  spec.description   = "Extracted reusable OpenAI API client that wraps chat completions with sane defaults, logging hooks, and retry/backoff handling."
  spec.homepage      = "https://github.com/gaetanjuvin/light-openai-lib"
  spec.license       = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.6")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "https://github.com/gaetanjuvin/light-openai-lib/issues"

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "lib/**/*",
      "examples/**/*",
      "README.md",
      "LICENSE.txt"
    ]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", ">= 0.18", "< 0.23"
  spec.add_dependency "base64", ">= 0.2", "< 1.0"
  spec.add_dependency "csv", ">= 3.0", "< 5.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"

end
