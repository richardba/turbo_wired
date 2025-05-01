module Turbo::SystemTestHelper
  def connect_turbo_cable_stream_sources(**options, &block)
    all(:turbo_cable_stream_source, **options, connected: false, wait: 0).each do |element|
      element.assert_matches_selector(:turbo_cable_stream_source, **options, connected: true, &block)
    end
  end

  def assert_turbo_cable_stream_source(...)
    assert_selector(:turbo_cable_stream_source, ...)
  end

  def assert_no_turbo_cable_stream_source(...)
    assert_no_selector(:turbo_cable_stream_source, ...)
  end

  Capybara.add_selector :turbo_cable_stream_source do
    xpath do |locator|
      xpath = XPath.descendant.where(XPath.local_name == "turbo-cable-stream-source")
      xpath.where(SignedStreamNameConditions.new(locator).reduce(:|))
    end

    expression_filter :connected do |xpath, value|
      builder(xpath).add_attribute_conditions(connected: value)
    end

    expression_filter :channel do |xpath, value|
      builder(xpath).add_attribute_conditions(channel: value.try(:name) || value)
    end

    expression_filter :signed_stream_name do |xpath, value|
      case value
      when TrueClass, FalseClass, NilClass, Regexp
        builder(xpath).add_attribute_conditions("signed-stream-name": value)
      else
        xpath.where(SignedStreamNameConditions.new(value).reduce(:|))
      end
    end
  end

  class SignedStreamNameConditions
    include Turbo::Streams::StreamName, Enumerable

    def initialize(value)
      @value = value
    end

    def attribute
      XPath.attr(:"signed-stream-name")
    end

    def each
      if @value.is_a?(String)
        yield attribute == @value
        yield attribute == signed_stream_name(@value)
      elsif @value.is_a?(Array) || @value.respond_to?(:to_key)
        yield attribute == signed_stream_name(@value)
      elsif @value.present?
        yield attribute == @value
      end
    end
  end
end
