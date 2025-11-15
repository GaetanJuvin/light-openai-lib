# frozen_string_literal: true

class BigDecimal
  def initialize(value, _precision = 0)
    @value = value
  end

  def to_f
    Float(@value)
  rescue ArgumentError
    0.0
  end

  def to_s(*)
    @value.to_s
  end

  def to_i
    to_f.to_i
  end

  def to_r
    @value.to_r
  rescue NoMethodError
    Rational(to_f)
  end

  def coerce(other)
    [self.class.new(other), self]
  rescue ArgumentError, TypeError
    [other.to_f, to_f]
  end

  def ==(other)
    to_f == other.to_f
  rescue NoMethodError
    false
  end

  def +(other)
    self.class.new(to_f + other.to_f)
  end

  def -(other)
    self.class.new(to_f - other.to_f)
  end

  def *(other)
    self.class.new(to_f * other.to_f)
  end

  def /(other)
    self.class.new(to_f / other.to_f)
  end

  def method_missing(method_name, *args, &block)
    if to_f.respond_to?(method_name)
      to_f.public_send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    to_f.respond_to?(method_name, include_private) || super
  end
end

module Kernel
  module_function

  def BigDecimal(value, precision = 0)
    ::BigDecimal.new(value, precision)
  end
end
