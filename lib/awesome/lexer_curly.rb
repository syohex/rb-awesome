module Awesome
  class LexerCurly
    KEYWORDS = %w(def class if while true false nil).freeze

    def tokenize(code)
      code.chomp!

      i = 0
      tokens = []
      current_indent = 0
      block_stack = []

      while i < code.size
        chunk = code[i..-1]

        if identifier = chunk[/\A([a-z]\w*)/, 1]
          if KEYWORDS.include?(identifier)
            tokens << [identifier.upcase.to_sym, identifier]
          else
            tokens << [:IDENTIFIER, identifier]
          end

          i += identifier.size
        elsif constant = chunk[/\A([A-Z]\w*)/, 1]
          tokens << [:CONSTANT, constant]
          i += constant.size
        elsif number = chunk[/\A([0-9]+)/, 1]
          tokens << [:NUMBER, number.to_i]
          i += number.size
        elsif string = chunk[/\A"(.*)?"/, 1]
          tokens << [:STRING, string]
          i += string.size + 2
        elsif chunk[/\A\{/m]
          current_indent += 2
          block_stack.push("{")
          tokens << [:INDENT, current_indent]
          i += 1
        elsif chunk[/\A\}/m]
          if block_stack.empty? || block_stack.last != "{"
            raise "Not found paired brace"
          end
          block_stack.pop
          current_indent -= 2
          tokens << [:DEDENT, current_indent]
          i += 1
        elsif chunk[/\A\n/m]
          tokens << [:NEWLINE, "\n"]
          i += 1
        elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
          tokens << [operator, operator]
          i += operator.size
        elsif chunk.match(/\A /)
          i += 1
        else
          value = chunk[0, 1]
          tokens << [value, value]
          i += 1
        end
      end

      unless block_stack.empty?
        raise "Missing '}'"
      end

      tokens
    end
  end
end
