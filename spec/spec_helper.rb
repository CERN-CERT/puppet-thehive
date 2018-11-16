require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

if Dir.exist?(File.expand_path('../lib', __dir__)) && RUBY_VERSION !~ /^1.9/
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ]
  SimpleCov.start do
    track_files 'lib/**/*.rb'
    add_filter '/spec'
    add_filter '/vendor'
    add_filter '/.vendor'
  end
end

RSpec.configure do |c|
  default_facts = {
    puppetversion: Puppet.version,
    facterversion: Facter.version
  }
  default_facts.merge!(YAML.safe_load(File.read(File.expand_path('default_facts.yml', __dir__)))) if File.exist?(File.expand_path('default_facts.yml', __dir__))
  default_facts.merge!(YAML.safe_load(File.read(File.expand_path('default_module_facts.yml', __dir__)))) if File.exist?(File.expand_path('default_module_facts.yml', __dir__))
  c.default_facts = default_facts

  c.hiera_config = File.expand_path('hiera.yaml', __dir__)

  # Coverage generation
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

# vim: syntax=ruby
