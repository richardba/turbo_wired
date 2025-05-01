module Turbo
  module TestAssertions
    extend ActiveSupport::Concern

    included do
      delegate :dom_id, :dom_class, to: ActionView::RecordIdentifier
    end

    def assert_turbo_stream(action:, target: nil, targets: nil, count: 1, &block)
      selector =  %(turbo-stream[action="#{action}"])
      selector << %([target="#{target.respond_to?(:to_key) ? dom_id(target) : target}"]) if target
      selector << %([targets="#{targets}"]) if targets
      assert_select selector, count: count, &block
    end

    def assert_no_turbo_stream(action:, target: nil, targets: nil)
      selector =  %(turbo-stream[action="#{action}"])
      selector << %([target="#{target.respond_to?(:to_key) ? dom_id(target) : target}"]) if target
      selector << %([targets="#{targets}"]) if targets
      assert_select selector, count: 0
    end
  end
end
