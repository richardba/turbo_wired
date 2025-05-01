Absolutely! Here's a cleaned-up, structured, and concise version of the Turbo/Hotwire README tailored to **showcase a project using Hotwire (Turbo + Stimulus) with Rails**, similar in tone and format to your earlier Docker/Next.js README. This makes it ideal for portfolio/demo purposes.

---

# ⚡ Hotwire with Rails

This guide introduces [Hotwire](https://hotwired.dev), a modern HTML-over-the-wire framework that drastically reduces the amount of JavaScript you need to build fast, dynamic web applications. It combines **Turbo** (for seamless page updates and navigation) and **Stimulus** (for small, focused JavaScript behaviors) in a full-stack Rails environment.

---

## 🧱 What is Hotwire?

Hotwire replaces the need for most front-end JavaScript frameworks by sending HTML over WebSockets or fetch requests, rather than JSON over REST APIs. It enables:

- **Turbo Drive** for fast navigation without full page reloads.
- **Turbo Frames** to update page sections without full replacements.
- **Turbo Streams** for real-time updates via WebSockets or HTTP.
- **Stimulus** to sprinkle in JavaScript when needed.

---

## 🔧 Installation

Hotwire is integrated by default in Rails 7+. If you're using Rails 6 or earlier, install manually:

1. Add the gem:

```ruby
# Gemfile
gem 'turbo-rails'
```

2. Install dependencies:

```bash
bundle install
bin/rails turbo:install
```

For stimulus support:

```bash
bin/rails stimulus:install
```

---

## 🚗 Turbo Drive (Fast Navigation)

Turbo Drive accelerates navigation by intercepting link clicks and form submissions, loading pages over `fetch`, and replacing the page body without a full reload.

To disable it globally:

```js
import "@hotwired/turbo-rails"
Turbo.session.drive = false
```

To enable or disable it per element:

```html
<a href="/page" data-turbo="false">Regular Link</a>
<form data-turbo="true">Turbo-enabled form</form>
```

📚 [Turbo Drive Docs](https://turbo.hotwired.dev/handbook/drive)

---

## 🧩 Turbo Frames (Componentized HTML Updates)

Turbo Frames let you update just a portion of the page instead of the whole document — perfect for modal forms, paginated tables, or user toolbars.

Example:

```erb
<%= turbo_frame_tag @todo do %>
  <p><%= @todo.description %></p>
  <%= link_to "Edit", edit_todo_path(@todo) %>
<% end %>
```

When the link is clicked, the frame is replaced by the corresponding frame from the next view.

📚 [Turbo Frames Docs](https://turbo.hotwired.dev/handbook/frames)

---

## 📡 Turbo Streams (Real-Time Updates)

Turbo Streams allow you to broadcast HTML updates to parts of the page using Action Cable or HTTP.

View example:

```erb
<%= turbo_stream_from dom_id(@todo) %>
```

Partial for stream:

```erb
<%= turbo_stream.append "todos", partial: "todos/todo", locals: { todo: @todo } %>
```

📚 [Turbo Streams Docs](https://turbo.hotwired.dev/handbook/streams)

---

## 🧠 Stimulus (Client-Side Behavior)

Stimulus enhances HTML with minimal JavaScript. It's great for handling toggles, modals, or AJAX previews.

Example controller:

```js
// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  greet() {
    this.outputTarget.textContent = "Hello, Hotwire!"
  }
}
```

Usage in HTML:

```erb
<div data-controller="hello">
  <button data-action="click->hello#greet">Click me</button>
  <span data-hello-target="output"></span>
</div>
```

📚 [Stimulus Docs](https://stimulus.hotwired.dev/)

---

## 🧪 Local Development

Start your Rails server and assets watcher:

```bash
bin/dev
```

Open your browser to [http://localhost:3000](http://localhost:3000) to see Hotwire in action.

---

## 🧪 Testing Turbo Streams

To ensure streams are rendered in tests, use:

```ruby
connect_turbo_cable_stream_sources
```

And configure Capybara for stream timing:

```ruby
# config/environments/test.rb
config.turbo.test_connect_after_actions << :click_link
```

---

## 🧰 Useful Links

- [Hotwire Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Hotwire Video Intro](https://hotwired.dev/#screencast)
- [Turbo Source Code](https://github.com/hotwired/turbo-rails)
- [Stimulus GitHub](https://github.com/hotwired/stimulus)

---

## 📜 License

This project is built with [Hotwire](https://hotwired.dev) and Rails. MIT License.

---

Let me know if you want this combined with your Docker/Next.js demo, exported as a portfolio, or deployed somewhere.