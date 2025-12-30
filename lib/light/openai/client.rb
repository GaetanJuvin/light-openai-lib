# frozen_string_literal: true

require "base64"
require "bigdecimal"
require "json"
require "httparty"
require "net/http"

module Light
  module OpenAI
    # Minimal chat client that wraps the OpenAI API with retry/backoff logic.
    class Client
      DEFAULT_API_URL = ENV.fetch("OPENAI_CHAT_COMPLETIONS_URL", "https://api.openai.com/v1/chat/completions").freeze
      DEFAULT_TIMEOUT = Integer(ENV.fetch("OPENAI_HTTP_TIMEOUT", 900))
      DEFAULT_RETRIES = Integer(ENV.fetch("OPENAI_HTTP_RETRIES", 2))
      DEFAULT_RETRY_INTERVAL = Float(ENV.fetch("OPENAI_HTTP_RETRY_INTERVAL", 1.5))

      def initialize(api_key:, api_url: DEFAULT_API_URL, timeout: DEFAULT_TIMEOUT, retries: DEFAULT_RETRIES, retry_interval: DEFAULT_RETRY_INTERVAL, logger: nil)
        raise ArgumentError, "api_key is required for OpenAIClient" if api_key.nil? || api_key.empty?

        @api_key = api_key
        @api_url = api_url
        @timeout = timeout
        @retries = [retries.to_i, 0].max
        @retry_interval = [retry_interval.to_f, 0].max
        @logger = logger
      end

      def chat(model:, messages:, temperature: 1, response_format: nil)
        payload = {
          model: model,
          messages: messages
        }
        
        # GPT-5 models don't support temperature parameter
        unless model.to_s.start_with?('gpt-5')
          payload[:temperature] = temperature
        end
        
        payload[:response_format] = response_format if response_format

        request(payload: payload, allow_fallback: !response_format.nil?)
      end

      private

      def request(payload:, allow_fallback:)
        attempts = 0
        max_attempts = @retries + 1

        loop do
          attempts += 1
          log_debug("POST #{@api_url} model=#{payload[:model]} (attempt #{attempts}/#{max_attempts})")

          response = nil
          begin
            response = HTTParty.post(
              @api_url,
              headers: {
                "Authorization" => "Bearer #{@api_key}",
                "Content-Type" => "application/json"
              },
              body: JSON.dump(payload),
              timeout: @timeout
            )
          rescue HTTParty::Error, SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
            if attempts < max_attempts
              wait = retry_delay(attempts)
              log_warn("OpenAI API request failed (#{e.class} #{e.message}) on attempt #{attempts}/#{max_attempts}; retrying in #{format('%.2f', wait)}s")
              sleep(wait)
              next
            end
            raise(StandardError, "OpenAI API request failed after #{attempts} attempts: #{e.class} #{e.message}")
          end

          if retryable_status?(response.code) && attempts < max_attempts
            wait = retry_delay(attempts)
            log_warn("OpenAI API HTTP #{response.code} on attempt #{attempts}/#{max_attempts}; retrying in #{format('%.2f', wait)}s")
            sleep(wait)
            next
          end

          body = nil
          begin
            body = parse_body(response.body)
          rescue JSON::ParserError => e
            if attempts < max_attempts
              wait = retry_delay(attempts)
              log_warn("Failed to parse OpenAI response on attempt #{attempts}/#{max_attempts}: #{e.message}. Retrying in #{format('%.2f', wait)}s")
              sleep(wait)
              next
            end
            raise(StandardError, "failed to parse OpenAI API response: #{e.message}")
          end

          if response.code == 400 && allow_fallback
            message = body.dig("error", "message").to_s
            if message.match?(/response_format/i)
              log_warn("response_format unsupported, retrying without JSON schema: #{message}")
              fallback_payload = payload.dup
              fallback_payload.delete(:response_format)
              return request(payload: fallback_payload, allow_fallback: false)
            end
          end

          unless response.code.between?(200, 299)
            error_message = body.dig("error", "message") || response.body
            raise(StandardError, "OpenAI API error (#{response.code}): #{error_message}")
          end

          return body
        end
      end

      def log_debug(message)
        @logger&.debug(message)
      end

      def log_warn(message)
        @logger&.warn(message)
      end

      def retryable_status?(code)
        return false if code.nil?

        code >= 500 || code == 429 || code == 408
      end

      def retry_delay(attempt)
        @retry_interval * (2**(attempt - 1))
      end

      def parse_body(raw_body)
        return {} if raw_body.to_s.strip.empty?

        JSON.parse(raw_body)
      end
    end
  end
end
