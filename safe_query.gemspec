# -*- encoding : utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include? lib

Gem::Specification.new do |s|
  s.name        = "safe_query"
  s.version     = "0.1.0"
  s.authors     = "Peter Cai"
  s.email       = "hello@petercai.com"
  s.homepage    = "https://github.com/pcai/safe_query"
  s.summary     = "Safely query stuff in ActiveRecord"
  s.description =  <<-EOF
    Helps developers avoid unsafe queries in ActiveRecord. This gem will raise an error 
    when iterating over a relation that is potentially unpaginated.
  EOF
  s.required_ruby_version = '>= 2.7.0'

  s.license = 'MIT'

  s.add_dependency "activerecord", ">= 5.0", "< 8.0"
  s.add_dependency "activesupport", ">= 5.0", "< 8.0"

  s.add_development_dependency "rspec", "~> 3.12"
  s.add_development_dependency "sqlite3", "~> 1.7.0"
  
  s.metadata["rubygems_mfa_required"] = "true"

  s.files = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*.rb']

  s.require_path = "lib"
end
