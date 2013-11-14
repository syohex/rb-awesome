require 'minitest/unit'
require 'minitest/autorun'

require 'awesome/lexer'

class TestLexer < MiniTest::Unit::TestCase
  def test_keywords
    Awesome::Lexer::KEYWORDS.each do |keyword|
      tokens = Awesome::Lexer.new.tokenize(keyword)
      assert_equal [keyword.upcase.to_sym, keyword], tokens.first
    end
  end

  def test_identifier
    %w(foo bar var).each do |identifier|
      tokens = Awesome::Lexer.new.tokenize(identifier)
      assert_equal [:IDENTIFIER, identifier], tokens.first
    end
  end

  def test_constant
    %w(Constant CONSTant CONSTANT).each do |constant|
      tokens = Awesome::Lexer.new.tokenize(constant)
      assert_equal [:CONSTANT, constant], tokens.first
    end
  end

  def test_number
    %w(1 9 100000 011111).each do |number|
      tokens = Awesome::Lexer.new.tokenize(number)
      assert_equal [:NUMBER, number.to_i], tokens.first
    end
  end

  def test_string
    tokens = Awesome::Lexer.new.tokenize("\"hoge\"")
    assert_equal [:STRING, "hoge"], tokens.first
  end

  def test_colon_indent
    tokens = Awesome::Lexer.new.tokenize(":\n  ")
    assert_equal [:INDENT, 2], tokens.first

    assert_raises(RuntimeError) do
      Awesome::Lexer.new.tokenize(":\n    :\n  ")
    end
  end

  def test_indent
    tokens = Awesome::Lexer.new.tokenize(":\n  \n  ")
    assert_equal [:NEWLINE, "\n"], tokens[1] # Last element is :DEDENT

    assert_raises(RuntimeError) do
      Awesome::Lexer.new.tokenize(":\n  \n    ")
    end
  end

  def test_operator
    %w(|| && == != <= >=).each do |op|
      tokens = Awesome::Lexer.new.tokenize(op)
      assert_equal [op, op], tokens.first
    end
  end

  def test_spaces
    tokens = Awesome::Lexer.new.tokenize("      ")
    assert_equal [], tokens
  end

  def test_one_char
    ['$', '%', '=', '+', '-'].each do |char|
      tokens = Awesome::Lexer.new.tokenize(char)
      assert_equal [char, char], tokens.first
    end
  end

  def test_summary
    code = <<-CODE
if 1:
  if 2:
    print "..."
    if false:
      pass
    print "done!"
  2
while 1:
  "in"

print "The End"
CODE

       tokens = [
         [:IF, "if"], [:NUMBER, 1],
         [:INDENT, 2],
         [:IF, "if"], [:NUMBER, 2],
         [:INDENT, 4],
         [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
         [:IF, "if"], [:FALSE, "false"],
         [:INDENT, 6],
         [:IDENTIFIER, "pass"],
         [:DEDENT, 4], [:NEWLINE, "\n"],
         [:IDENTIFIER, "print"], [:STRING, "done!"],
         [:DEDENT, 2], [:NEWLINE, "\n"],
         [:NUMBER, 2],
         [:DEDENT, 0], [:NEWLINE, "\n"],
         [:WHILE, "while"], [:NUMBER, 1],
         [:INDENT, 2],
         [:STRING, "in"],
         [:DEDENT, 0], [:NEWLINE, "\n"],
         [:NEWLINE, "\n"],
         [:IDENTIFIER, "print"], [:STRING, "The End"]
       ]

       assert_equal tokens, Awesome::Lexer.new.tokenize(code)
  end
end
