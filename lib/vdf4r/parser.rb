require 'treetop'
require 'vdf4r/store'

MAX_RECURSION = 10
GRAMMAR_PATH  = File.join(File.dirname(__FILE__), '..', 'vdf.tt')

Treetop.load GRAMMAR_PATH

module VDF4R
  class Parser
    class << self
      def clean(input)
        input.gsub(/\\"/, '&{QUOTE}')
      end

      def dirty(input)
        input.gsub('&{QUOTE}', '\"')
      end
    end

    def initialize(input)
      case
      when input.respond_to?(:each_line)
        @input = input.each_line.to_a
      when input.respond_to?(:lines)
        @input = input.lines
      else
        raise ArgumentError.new('input must respond to #each_line or #lines')
      end
    end

    def parse
      parser = VDF4R::KeyValuesParser.new
      store  = Store.new
      key    = nil
      path   = []

      @input.each do |line|
        node = parser.parse(Parser.clean(line))
        raise "ungrammatical content: '#{line}'" if node.nil?

        _, (encounter, context) = node.value

        case encounter
        when :blank, :comment
          # do nothing
        when :enter_object
          raise 'no preceding key for object' unless key
          raise 'too recursive' if path.length > MAX_RECURSION
          path.push key
          key = nil
        when :exit_object
          raise 'nesting unbalanced (excessive exit)' if path.empty?
          path.pop
        when :key
          key = context[0]
        when :key_value
          k, v = context
          store.traverse(path)[k] = Parser.dirty(v)
        else
          raise 'unknown node value'
        end
      end

      raise 'nesting unbalanced (insufficient exit)' unless path.empty?

      store
    end
  end
end
