require 'treetop'
require 'vdf4r/store'

MAX_RECURSION = 10
GRAMMAR_PATH  = File.join(File.dirname(__FILE__), '..', 'vdf.tt')

Treetop.load GRAMMAR_PATH

module VDF4R
  class Parser
    class << self
      def clean(input)
        input.gsub(/\\"/, '&quot;')
      end

      def dirty(input)
        input.gsub('&quot;', '\"')
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

    def parse(keep_only=nil)
      parser        = VDF4R::KeyValuesParser.new
      store         = Store.new
      key           = nil
      partial_value = nil
      path          = []

      @input.each_with_index do |line, index|
        node = parser.parse(Parser.clean(line))

        if node.nil?
          raise "ungrammatical content at line #{index+1}: '#{line}'" if node.nil?
        end

        begin
          _, (encounter, context) = node.value
        rescue NoMethodError => e
          
        end

        case encounter
        when :blank, :comment
          # do nothing
        when :enter_object
          raise 'no preceding key for object' unless key
          raise 'too recursive' if path.length > MAX_RECURSION
          raise 'enter during multi-line value' if partial_value
          path.push key
          key = nil
        when :exit_object
          raise 'nesting unbalanced (excessive exit)' if path.empty?
          raise 'exit during multi-line value' if partial_value
          path.pop
        when :key_value
          k, v = context
          if keep_only.nil? or (path.include? keep_only or k == keep_only)
            store.traverse(path)[k] = Parser.dirty(v)
          end
        when :key
          key = context[0]
        when :key_enter_value
          key, partial_value = context
        when :key_continue_value
          # raise unless value is non-nil
          partial_value += "\n#{context[0]}"
        when :key_exit_value
          v = partial_value + "\n#{context[0]}"
          partial_value = nil
          if keep_only.nil? or (path.include? keep_only or key == keep_only)
            store.traverse(path)[key] = Parser.dirty(v)
          end
        else
          raise 'unknown node value'
        end
      end

      raise 'nesting unbalanced (insufficient exit)' unless path.empty?

      store
    end
  end
end
