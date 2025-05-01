require "test_helper"
require "turbo/system_test_helper"
require "capybara/minitest"

class Turbo::CapybaraSelectorTestCase < ActionView::TestCase
  include Capybara::Minitest::Assertions

  attr_accessor :page

  def render_html(html, **local_assigns)
    render(inline: html, locals: local_assigns)
    self.page = Capybara.string(rendered.to_s)
  end
end

class Turbo::TurboCableStreamSourceSelectorTest < Turbo::CapybaraSelectorTestCase
  setup do
    @message = Message.new(id: 1)
    render_html <<~ERB, message: @message
      <%= turbo_stream_from message %>
    ERB
  end

  test "matches selector using various stream name representations" do
    assert_selector :turbo_cable_stream_source, count: 1
    assert_selector :turbo_cable_stream_source, @message, count: 1
    assert_selector :turbo_cable_stream_source, [@message], count: 1
    assert_selector :turbo_cable_stream_source, Turbo::StreamsChannel.signed_stream_name(@message), count: 1
  end

  test "matches selector using :signed_stream_name filter" do
    assert_selector :turbo_cable_stream_source, signed_stream_name: @message, count: 1
    assert_selector :turbo_cable_stream_source, signed_stream_name: [@message], count: 1
    assert_selector :turbo_cable_stream_source, signed_stream_name: Turbo::StreamsChannel.signed_stream_name(@message), count: 1
  end

  test "matches selector using :channel filter with valid types" do
    assert_selector :turbo_cable_stream_source, channel: true
    assert_selector :turbo_cable_stream_source, channel: Turbo::StreamsChannel
    assert_selector :turbo_cable_stream_source, channel: "Turbo::StreamsChannel"
  end

  test "does not match incorrect stream name as locator" do
    invalid_message = Message.new(id: 2)
    assert_no_selector :turbo_cable_stream_source, "junk", count: 1
    assert_no_selector :turbo_cable_stream_source, invalid_message, count: 1
    assert_no_selector :turbo_cable_stream_source, [invalid_message], count: 1
    assert_no_selector :turbo_cable_stream_source, Turbo::StreamsChannel.signed_stream_name(invalid_message), count: 1
  end

  test "does not match incorrect stream name using :signed_stream_name filter" do
    invalid_message = Message.new(id: 2)
    assert_no_selector :turbo_cable_stream_source, signed_stream_name: "junk", count: 1
    assert_no_selector :turbo_cable_stream_source, signed_stream_name: invalid_message, count: 1
    assert_no_selector :turbo_cable_stream_source, signed_stream_name: [invalid_message], count: 1
    assert_no_selector :turbo_cable_stream_source, signed_stream_name: Turbo::StreamsChannel.signed_stream_name(invalid_message), count: 1
  end

  test "does not match selector using invalid :channel filter" do
    assert_no_selector :turbo_cable_stream_source, channel: false
    assert_no_selector :turbo_cable_stream_source, channel: Object
    assert_no_selector :turbo_cable_stream_source, channel: "Object"
  end

  test "no turbo_cable_stream_source present if not rendered at all" do
    render_html "<div>No stream source here</div>"
    assert_no_selector :turbo_cable_stream_source
  end
end
