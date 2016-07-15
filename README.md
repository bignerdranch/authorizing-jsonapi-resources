# Authorizing JSONAPI::Resources

A tutorial for applying authorization rules with JSONAPI::Resources.

It can be accessed directly via a web service client like `curl` or Postman, or via the [Authorizing JSONAPI::Resources Client][client] Ember app.

## Requirements

* Ruby 2.2.2 or newer
* Postgres 8.4 or newer

## Installation

```
bundle install
bin/rails db:setup
bin/sample-data
bin/rails serve
```

Check `bin/sample-data` for test user accounts.

## License

MIT

[client]: https://github.com/bignerdranch/authorizing-jsonapi-resources-client
