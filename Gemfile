source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "puppet-lint"
  gem "puppet-syntax"
end

group :development do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "puppet-lint"
  gem "puppet-syntax"
end

group :travis_ci do
  gem "travis"
  gem "travis-lint"
end

group :system_tests do
  gem "vagrant-wrapper"
  gem "beaker"
  gem "beaker-rspec"
end
