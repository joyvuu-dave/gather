require 'rspec/expectations'

RSpec::Matchers.define :have_subdomain do |subdomain|
  match do |url|
    subdomain += "." unless subdomain.nil?
    url =~ %r{\Ahttp://#{subdomain}#{Settings.url.host}}
  end
end

RSpec::Matchers.define :have_subdomain_and_path do |subdomain, path|
  match do |url|
    subdomain += "." unless subdomain.nil?
    url =~ %r{\Ahttp://#{subdomain}#{Settings.url.host}(:#{Settings.url.port})?#{Regexp.escape(path)}\z}
  end
end

RSpec::Matchers.define :match_expectation_file do |file|
  match do |actual|
    actual == File.read(Rails.root.join("spec", "expectations", file))
  end
  diffable
end
