# Light OpenAI Lib

A tiny, dependency-light wrapper for the OpenAI Chat Completions API. It extracts the reusable client that powers several of my Ruby projects and packages it as a gem so it can be reused without copy/paste.

## Installation

Add the gem to your Gemfile:

```ruby
gem "light-openai-lib"
```

and run `bundle install`.

If you are not using Bundler install it directly:

```sh
gem install light-openai-lib
```

## Usage

```ruby
require "light/openai"

client = Light::OpenAI::Client.new(
  api_key: ENV.fetch("OPENAI_API_KEY"),
  logger: Logger.new($stdout)
)

response = client.chat(
  model: "gpt-4o-mini",
  messages: [
    { role: "system", content: "You are a helpful assistant." },
    { role: "user", content: "Tell me a joke about Ruby." }
  ],
  temperature: 0.4
)

puts response.dig("choices", 0, "message", "content")
```

Environment variables control sane defaults:

| Variable | Purpose | Default |
| --- | --- | --- |
| `OPENAI_CHAT_COMPLETIONS_URL` | API base URL | `https://api.openai.com/v1/chat/completions` |
| `OPENAI_HTTP_TIMEOUT` | Request timeout in seconds | `900` |
| `OPENAI_HTTP_RETRIES` | Number of retry attempts | `2` |
| `OPENAI_HTTP_RETRY_INTERVAL` | Initial retry delay (exponential backoff) | `1.5` |

You can also pass `response_format:` to `#chat` to opt into JSON mode. If the OpenAI API responds with a `response_format` error the client automatically falls back to a standard request and returns the first success payload.

## Examples

This repo carries runnable scripts under `examples/`. The simplest one invokes the client with your OpenAI key:

```sh
OPENAI_API_KEY=sk-... bundle exec ruby examples/chat.rb "Explain compounding interest like I'm 12"
```

## Compatibility

- Ruby 3.0+
- No runtime dependencies besides [`httparty`](https://github.com/jnunemaker/httparty)

## Development

After checking out the repo, run:

```sh
bundle install
bundle exec rake test
```

`bin/console` gives you a REPL with the gem loaded. Update the version in `lib/light/openai/version.rb` before publishing, then build and push:

```sh
bundle exec rake build
gem push pkg/light-openai-lib-<version>.gem
```
