require 'treetop'
require 'vdf4r/store'

MAX_RECURSION = 10
GRAMMAR_PATH  = File.join(File.dirname(__FILE__), '..', 'vdf.tt')

Treetop.load GRAMMAR_PATH

module VDF4R
  class Parser
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
        node = parser.parse(line)
        raise "ungrammatical content: '#{line}'" if node.nil?

        next if [:blank, :comment].include?(node.value)

        if node.value.respond_to?(:to_ary)
          case node.value.length
          when 1
            key = node.value.first
          when 2
            k, v = node.value
            store.traverse(path)[k] = v
          end
        elsif node.value.kind_of?(Symbol)
          case node.value
          when :enter_object
            raise 'no preceding key for object' unless key
            raise 'too recursive' if path.length > MAX_RECURSION
            path.push key
            key = nil
          when :exit_object
            raise 'nesting unbalanced (excessive exit)' if path.empty?
            path.pop
          end
        end
      end

      raise 'nesting unbalanced (insufficient exit)' unless path.empty?

      store
    end
  end
end
