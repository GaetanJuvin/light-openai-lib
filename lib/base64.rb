# frozen_string_literal: true

native_loaded = false

begin
  require "rbconfig"
  native_file = File.join(RbConfig::CONFIG["rubylibdir"], "base64.rb")
  if native_file && File.exist?(native_file)
    load native_file
    native_loaded = true
  end
rescue LoadError
  native_loaded = false
end

require_relative "light/openai/base64_fallback" unless native_loaded
