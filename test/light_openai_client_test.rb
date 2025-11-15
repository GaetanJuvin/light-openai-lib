# frozen_string_literal: true

require "json"
require "test_helper"

class LightOpenAIClientTest < Minitest::Test
  Response = Struct.new(:code, :body)

  def setup
    @client = Light::OpenAI::Client.new(api_key: "test", retries: 0, logger: nil)
  end

  def test_successful_chat_returns_body
    payload = { "choices" => [] }
    HTTParty.stub(:post, Response.new(200, payload.to_json)) do
      result = @client.chat(model: "gpt-4o-mini", messages: [])
      assert_equal payload, result
    end
  end

  def test_openai_client_alias
    assert_same Light::OpenAI::Client, OpenAIClient
  end
end
