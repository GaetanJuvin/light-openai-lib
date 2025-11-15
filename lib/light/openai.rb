# frozen_string_literal: true

require_relative "openai/version"
require_relative "openai/client"

module Light
  module OpenAI
    class Error < StandardError; end
  end
end

# Backwards compatibility for applications that previously referenced OpenAIClient directly.
OpenAIClient = Light::OpenAI::Client unless defined?(OpenAIClient)
