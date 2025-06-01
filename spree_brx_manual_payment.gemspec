# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_brx_manual_payment/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_brx_manual_payment'
  s.version     = SpreeBrxManualPayment::VERSION
  s.summary     = "Spree Commerce Brx manual payment Extension"
  s.required_ruby_version = '>= 3.0'

  s.author    = 'You'
  s.email     = 'you@example.com'
  s.homepage  = 'https://github.com/your-github-handle/spree_brx_manual_payment'
  s.license = 'AGPL-3.0-or-later'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 4.3.0.rc1'
  s.add_dependency 'spree', spree_version
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_emails', spree_version
  s.add_dependency 'spree_extension'

  s.add_dependency 'spree_core', spree_version

  s.add_development_dependency 'spree_dev_tools'
end
