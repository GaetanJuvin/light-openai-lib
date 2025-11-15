# frozen_string_literal: true

module Base64
  module_function

  def encode64(string)
    [String(string)].pack("m")
  end

  def decode64(encoded)
    String(encoded).unpack1("m")
  end
end
