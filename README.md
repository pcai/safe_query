# SafeQuery

Safely query stuff in ActiveRecord.

## Why

To prevent unbounded resource consumption, we always want to limit how many rows can be returned from database fetches.

Calls to `ActiveRecord::Relation#each` (without a LIMIT clause) are dangerous and should be avoided, because they can accidentally trigger an 
unpaginated database fetch for millions of rows, which can exhaust your web server or database resources. Exceptions to this rule should be carefully vetted. 

Worse, it's common to hit this problem only in production, because development environments seldom contain enough database rows to highlight the issue. 
This makes it easy to write code that seems to work well, but fails when operating on a database with more data.

This gem raises an exception whenever you attempt to call `ActiveRecord::Relation#each`, giving you the opportunity to catch and fix 
this before any unsafe code hits production.

## How it works

With this gem installed, Rails will throw an exception when you make an unsafe query:

![image](https://user-images.githubusercontent.com/222655/227005861-a9ab39cc-dfa9-4adc-8c30-e71bd2b73fb9.png)

## Compatibility:

- Rails 5+
- Ruby 2.7+
- Postgres, MySQL, SQLite, maybe others (untested)

## Installation:

Add to your gemfile:

```
gem 'safe_query', group: [:development, :test]
```

then `bundle install`.

It's recommended to set `config.active_record.warn_on_records_fetched_greater_than` (available since Rails 5), so you have warnings 
whenever a query is returning more rows than expected, even when using this gem. 
For example, if your app is never supposed to have no more than 100 records per page, add to `config/environments/development.rb`:

```ruby
  config.active_record.warn_on_records_fetched_greater_than = 100
```

## Example fixes:

### Use `find_each` instead

Sometimes the fix is as easy as changing

```ruby
book.authors.each do |author|
```

to this:

```ruby
book.authors.find_each do |author|
```

Sometimes this doesn't work:
- For some reason you don't have an autoincrementing primary key ID for Rails to paginate on
- You have a specific sort order and you want to maintain the sort order

In those cases, you may have to add some custom code to maintain your existing app behavior. But otherwise, you can 
use `find_each` or any other solution from the [ActiveRecord::Batches](https://api.rubyonrails.org/classes/ActiveRecord/Batches.html) API.

### Paginate your results

Use your existing pagination solution, or look at adding [pagy](https://github.com/ddnexus/pagy), [kaminari](https://github.com/kaminari/kaminari), 
[will_paginate](https://github.com/mislav/will_paginate), etc to your app.

### Just add a `limit` clause

Sometimes you are simply missing a limit clause in your query. This might be the case if you have an implied 
upper bound on the number of results enforced by the application elsewhere. SafeQuery will find cases where this limit isn't expressed in your queries, 
which might be a problem if your enforcement logic is flawed in some way.

### Ignore this problem

You can ignore this problem by converting the relation to an array with `to_a` before you operate on it:

```ruby
book.authors.find_by ...
```

to this:

```ruby
book.authors.to_a.find_by ...
```

# Contributing

- Fork repository
- `bundle install`
- Make your change, add tests, and ensure they are passing with `bundle exec rspec`
- Open pull request
