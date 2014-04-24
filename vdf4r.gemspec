# encoding: utf-8

pwd = File.dirname(__FILE__)

require File.join(pwd, 'lib', 'vdf4r', 'version.rb')

Gem::Specification.new do |s|
  s.name        = 'vdf4r'
  s.version     = VDF4R::VERSION
  s.date        = %q{2014-04-24}
  s.licenses    = ['MIT']
  s.summary     = "Valve Data Format (VDF) file parser"
  s.description = "See README at https://github.com/skadistats/vdf4r"

  s.authors  = ['Joshua Morris']
  s.email    = 'onethirtyfive@skadistats.com'
  s.homepage = 'https://github.com/skadistats/vdf4r'
  s.files    = Dir['{lib,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  s.add_dependency('treetop', '>=1.5.0')
  s.add_development_dependency('rspec', '>=2.14.1')
end
