module FixtureHelpers
  def with_fixture(name, &block)
    abspath = File.join(File.dirname(__FILE__), 'fixtures', *name.split('/'))
    File.open("#{abspath}.txt") do |fixture|
      yield fixture
    end
  end
end

RSpec.configure do |c|
  c.include FixtureHelpers
end
