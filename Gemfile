source "https://rubygems.org"

# Note: This application cannot be updated to Ruby 3 yet, see https://talk.jekyllrb.com/t/error-no-implicit-conversion-of-hash-into-integer/5890
ruby '3.2.0'

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
# gem "jekyll-remote-theme"
gem "github-pages", ">= 227", group: :jekyll_plugins

# This is the default theme for new Jekyll sites. You may change this to anything you like.
gem "minima", "~> 2.0"

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.15"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.0" if Gem.win_platform?

begin
  gem 'webrick' unless RUBY_VERSION.split('.').first.to_i <= 2
rescue
  raise "Cannot determine Ruby major version from RUBY_VERSION #{RUBY_VERSION.inspect}"
end
