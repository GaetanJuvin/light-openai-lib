#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "light/openai"
require "logger"

abort "Set OPENAI_API_KEY before running." unless ENV["OPENAI_API_KEY"]

prompt = ARGV.empty? ? "Say hello like a pirate." : ARGV.join(" ")
model = ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")

client = Light::OpenAI::Client.new(
  api_key: ENV.fetch("OPENAI_API_KEY"),
  logger: Logger.new($stdout)
)

messages = [
  { role: "system", content: "You are a friendly assistant." },
  { role: "user", content: prompt }
]

response = client.chat(model: model, messages: messages, temperature: 0.6)

content = response.dig("choices", 0, "message", "content")
puts(content || "<no response>")
