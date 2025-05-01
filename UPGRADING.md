## Key Digest Changes in 1.1.1

Starting with Turbo Rails 1.1.1, a bug that caused applications to default to SHA1 for deriving application secrets—despite specifying a different digest class in `config.active_support.key_generator_hash_digest_class`—has been resolved. This issue primarily affects applications using Rails 7, which defaults to SHA256 for key generation.

This fix may lead to unexpected changes in application secrets when upgrading. For applications using ActiveStorage, this change impacts the secret used by its message verifier, potentially making previously stored assets [inaccessible][2].

### Mitigation Steps

If your application is affected, you can implement key rotation to maintain access to old asset digests. Add the following code to a file in `config/initializers`:

```ruby
Rails.application.config.after_initialize do |app|
  key_generator = ActiveSupport::KeyGenerator.new app.secret_key_base,
    iterations: 1000,
    hash_digest_class: OpenSSL::Digest::SHA1

  app.message_verifier("ActiveStorage").rotate(key_generator.generate_key("ActiveStorage"))
end
```

Alternatively, you can configure your application to continue using SHA1-based secrets by adding this line to your configuration:

```ruby
config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1
```

For more details, refer to the [pull request][1] and the related [issue][2].

[1]: https://github.com/hotwired/turbo-rails/pull/335
[2]: https://github.com/hotwired/turbo-rails/issues/340

---

## Upgrading from Rails UJS / Turbolinks to Turbo

Turbo replaces Rails UJS and Turbolinks for handling links and form submissions via XMLHttpRequests. If you're transitioning fully to Turbo, ensure the following configuration is set in `config/application.rb`:

```ruby
config.action_view.form_with_generates_remote_forms = false
```

For applications requiring Rails UJS and Turbo to coexist, follow these steps:

### 1. Update Rails UJS Selectors

Ensure you're using a compatible version of Rails UJS or the jquery-ujs plugin. You may need to vendor the JavaScript file and make adjustments. See [this pull request](https://github.com/rails/rails/pull/42476) for details.

### 2. Replace the Turbolinks Gem

Replace `gem 'turbolinks'` with `gem 'turbo-rails'` in your Gemfile. To maintain compatibility with old-style XMLHttpRequests, add the following shim to `app/controllers/concerns/turbo/redirection.rb` and include it in `ApplicationController`:

```ruby
module Turbo
  module Redirection
    extend ActiveSupport::Concern

    def redirect_to(url = {}, options = {})
      turbo = options.delete(:turbo)

      super.tap do
        if turbo != false && request.xhr? && !request.get?
          visit_location_with_turbo(location, turbo)
        end
      end
    end

    private

    def visit_location_with_turbo(location, action)
      visit_options = { action: action.to_s == "advance" ? action : "replace" }

      script = [
        "Turbo.cache.clear()",
        "Turbo.visit(#{location.to_json}, #{visit_options.to_json})"
      ]

      self.status = 200
      self.response_body = script.join("\n")
      response.content_type = "text/javascript"
      response.headers["X-Xhr-Redirect"] = location
    end
  end
end
```

Additionally, include the following helper in `test/helpers/turbo_assertions_helper.rb`:

```ruby
module TurboAssertionsHelper
  TURBO_VISIT = /Turbo\.visit\("([^"]+)", {"action":"([^"]+)"}\)/

  def assert_redirected_to(options = {}, message = nil)
    turbo_request? ? assert_turbo_visited(options, message) : super
  end

  def assert_turbo_visited(options = {}, message = nil)
    assert_response(:ok, message)
    assert_equal("text/javascript", response.media_type || response.content_type)

    visit_location, _ = turbo_visit_location_and_action

    redirect_is = normalize_argument_to_redirection(visit_location)
    redirect_expected = normalize_argument_to_redirection(options)

    message ||= "Expected Turbo visit to <#{redirect_expected}>, but was <#{redirect_is}>"
    assert_operator redirect_expected, :===, redirect_is, message
  end

  def turbo_request?
    !request.get? && (response.media_type || response.content_type) == "text/javascript"
  end

  def turbo_visit_location_and_action
    response.body =~ TURBO_VISIT ? [$1, $2] : nil
  end
end
```

### 3. Update JavaScript Imports

Replace `require("turbolinks").start()` with:

```javascript
import "@hotwired/turbo-rails";
```

Turbo starts automatically upon import.

### 4. Update Namespaces

Replace all `turbolinks` namespaces with `turbo`. For example:

- `turbolinks:before-cache` → `turbo:before-cache`
- `Turbolinks.visit` → `Turbo.visit`
- `data-turbolinks-action` → `data-turbo-action`

### 5. Optional: Mobile Adapter Shims

If you use Turbolinks mobile adapters, you may need a compatibility shim. Here's an example:

```javascript
window.Turbolinks = {
  visit: Turbo.visit,
  controller: {
    isDeprecatedAdapter(adapter) {
      return typeof adapter.visitProposedToLocation !== "function";
    },
    startVisitToLocationWithAction(location, action, restorationIdentifier) {
      window.Turbo.navigator.startVisit(location, restorationIdentifier, { action });
    },
    get restorationIdentifier() {
      return window.Turbo.navigator.restorationIdentifier;
    },
    get adapter() {
      return window.Turbo.navigator.adapter;
    },
    set adapter(adapter) {
      if (this.isDeprecatedAdapter(adapter)) {
        adapter.visitProposedToLocation = function(location, options) {
          adapter.visitProposedToLocationWithAction(location, options.action);
        };

        const adapterVisitStarted = adapter.visitStarted;
        adapter.visitStarted = function(visit) {
          Object.defineProperties(visit.location, {
            absoluteURL: {
              configurable: true,
              get() { return this.toString(); }
            }
          });

          adapter.currentVisit = visit;
          adapterVisitStarted(visit);
        };
      }

      window.Turbo.registerAdapter(adapter);
    }
  }
};

document.addEventListener("turbo:load", function() {
  const event = new CustomEvent("turbolinks:load", { bubbles: true });
  document.documentElement.dispatchEvent(event);
});
```
