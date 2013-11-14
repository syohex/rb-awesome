require 'minitest/unit'
require 'minitest/autorun'

require 'awesome/lexer_curly'

class TestLexer < MiniTest::Unit::TestCase
  def test_keywords
    Awesome::LexerCurly::KEYWORDS.each do |keyword|
      tokens = Awesome::LexerCurly.new.tokenize(keyword)
      assert_equal [keyword.upcase.to_sym, keyword], tokens.first
    end
  end

  def test_identifier
    %w(foo bar var).each do |identifier|
      tokens = Awesome::LexerCurly.new.tokenize(identifier)
      assert_equal [:IDENTIFIER, identifier], tokens.first
    end
  end

  def test_constant
    %w(Constant CONSTant CONSTANT).each do |constant|
      tokens = Awesome::LexerCurly.new.tokenize(constant)
      assert_equal [:CONSTANT, constant], tokens.first
    end
  end

  def test_number
    %w(1 9 100000 011111).each do |number|
      tokens = Awesome::LexerCurly.new.tokenize(number)
      assert_equal [:NUMBER, number.to_i], tokens.first
    end
  end

  def test_string
    tokens = Awesome::LexerCurly.new.tokenize("\"hoge\"")
    assert_equal [:STRING, "hoge"], tokens.first
  end

  def test_left_curly
    tokens = Awesome::LexerCurly.new.tokenize("{}")
    assert_equal [:INDENT, 2], tokens.first
  end

  def test_right_curly
    tokens = Awesome::LexerCurly.new.tokenize("{}")
    assert_equal [:DEDENT, 0], tokens.last

    assert_raises(RuntimeError) do
      Awesome::LexerCurly.new.tokenize("}")
    end
  end

  def test_invalid_pair
    assert_raises(RuntimeError) do
      Awesome::LexerCurly.new.tokenize("{}}")
    end
  end

  def test_operator
    %w(|| && == != <= >=).each do |op|
      tokens = Awesome::LexerCurly.new.tokenize(op)
      assert_equal [op, op], tokens.first
    end
  end

  def test_spaces
    tokens = Awesome::LexerCurly.new.tokenize("      ")
    assert_equal [], tokens
  end

  def test_one_char
    ['$', '%', '=', '+', '-'].each do |char|
      tokens = Awesome::LexerCurly.new.tokenize(char)
      assert_equal [char, char], tokens.first
    end
  end

  def test_summary
    code = <<-CODE
if 1 {
  if 2 {
    print "..."
    if false {
      pass
    }
    print "done!"
  }
  2
}
while 1 {
  "in"
}

print "The End"
CODE

       tokens = [
         [:IF, "if"], [:NUMBER, 1],
         [:INDENT, 2], [:NEWLINE, "\n"],
         [:IF, "if"], [:NUMBER, 2],
         [:INDENT, 4], [:NEWLINE, "\n"],
         [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
         [:IF, "if"], [:FALSE, "false"],
         [:INDENT, 6], [:NEWLINE, "\n"],
         [:IDENTIFIER, "pass"], [:NEWLINE, "\n"],
         [:DEDENT, 4], [:NEWLINE, "\n"],
         [:IDENTIFIER, "print"], [:STRING, "done!"], [:NEWLINE, "\n"],
         [:DEDENT, 2], [:NEWLINE, "\n"],
         [:NUMBER, 2], [:NEWLINE, "\n"],
         [:DEDENT, 0], [:NEWLINE, "\n"],
         [:WHILE, "while"], [:NUMBER, 1], [:INDENT, 2], [:NEWLINE, "\n"],
         [:STRING, "in"], [:NEWLINE, "\n"],
         [:DEDENT, 0], [:NEWLINE, "\n"],
         [:NEWLINE, "\n"],
         [:IDENTIFIER, "print"], [:STRING, "The End"]
       ]

       assert_equal tokens, Awesome::LexerCurly.new.tokenize(code)
  end
end
