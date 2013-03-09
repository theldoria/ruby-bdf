# -*- coding: utf-8 -*-
require_relative 'helper'
require 'bdf'

TEST_FILES_DIR = File.join(File.dirname(__FILE__), "test-files")
TEST_FILE_TOM = File.join(TEST_FILES_DIR, "tom-thumb.bdf")
TEST_FILE_EXAMPLE1 = File.join(TEST_FILES_DIR, "example1.bdf")

class TestBdf < Test::Unit::TestCase
  def test_version
    version = Bdf.const_get('VERSION')

    assert !version.empty?, 'should have a VERSION constant'
  end

  def setup
    @bdf = Bdf.load(TEST_FILE_TOM)
  end

  def test_load
    assert @bdf
  end

  def test_load_non_existing_file
    assert !Bdf.load(File.join(TEST_FILES_DIR, "non-existing-file"))
  end

  def test_load_content_font
    assert_equal '-Raccoon-Fixed4x6-Medium-R-Normal--6-60-75-75-P-40-ISO10646-1', @bdf.font
  end

  def test_load_content_size
    assert_equal [6, 75, 75], @bdf.size
  end

  def test_load_content_bounding_box
    expected = {x:3, y:6, displacement:{x:0, y:-1}}
    assert_equal expected, @bdf.bounding_box
  end

  def test_load_content_properties
    expected = {:font_name=>"Fixed4x6", :font_ascent=>5, :font_descent=>1}
    assert_equal expected, @bdf.properties
  end

  def test_load_content_chars
    expected = ["space", "exclam", "quotedbl", "numbersign", "dollar", "percent", "ampersand", "quotesingle", "parenleft", "parenright", "asterisk", "plus", "comma", "hyphen", "period", "slash", "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "colon", "semicolon", "less", "equal", "greater", "question", "at", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "bracketleft", "backslash", "bracketright", "asciicircum", "underscore", "grave", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "braceleft", "bar", "braceright", "asciitilde", "exclamdown", "cent", "sterling", "currency", "yen", "brokenbar", "section", "dieresis", "copyright", "ordfeminine", "guillemotleft", "logicalnot", "softhyphen", "registered", "macron", "degree", "plusminus", "twosuperior", "threesuperior", "acute", "mu", "paragraph", "periodcentered", "cedilla", "onesuperior", "ordmasculine", "guillemotright", "onequarter", "onehalf", "threequarters", "questiondown", "Agrave", "Aacute", "Acircumflex", "Atilde", "Adieresis", "Aring", "AE", "Ccedilla", "Egrave", "Eacute", "Ecircumflex", "Edieresis", "Igrave", "Iacute", "Icircumflex", "Idieresis", "Eth", "Ntilde", "Ograve", "Oacute", "Ocircumflex", "Otilde", "Odieresis", "multiply", "Oslash", "Ugrave", "Uacute", "Ucircumflex", "Udieresis", "Yacute", "Thorn", "germandbls", "agrave", "aacute", "acircumflex", "atilde", "adieresis", "aring", "ae", "ccedilla", "egrave", "eacute", "ecircumflex", "edieresis", "igrave", "iacute", "icircumflex", "idieresis", "eth", "ntilde", "ograve", "oacute", "ocircumflex", "otilde", "odieresis", "divide", "oslash", "ugrave", "uacute", "ucircumflex", "udieresis", "yacute", "thorn", "ydieresis", "gcircumflex", "OE", "oe", "Scaron", "scaron", "Ydieresis", "Zcaron", "zcaron", "uni0EA4", "uni13A0", "bullet", "ellipsis", "Euro", "uniFFFD"].map(&:to_sym)
    assert_equal expected, @bdf.chars.keys
  end

  def test_load_content_chars_f_properties
    expected = {:device_width=>[4, 0], :bounding_box=>{x:3, y:5, displacement:{x:0, y:0}}, :encoding=>102, :bitmap=>[32, 64, 224, 64, 64]}
    assert_equal expected, @bdf.chars[:f]
  end

  def test_load_content_chars_space_properties
    expected = {:device_width=>[4, 0], :bounding_box=>{x:1, y:1, displacement:{x:3, y:4}}, :encoding=>32, :bitmap=>[0]}
    assert_equal expected, @bdf.chars[:space]
  end

  def test_load_nine
    bbx = @bdf.bounding_box
#    puts @bdf.char_to_s(:nine, 0, bbx[:y] - 1)
  end

  def test_load_print
    bbx = @bdf.bounding_box
    screen = @bdf.create_bounding_box_array(160, 43)
    keys = @bdf.chars.keys.reverse
    7.times do |row|
      x = 0
      y = bbx[:y] * row
      40.times do
        _, x, y = @bdf.print_char(screen, keys.pop, x, y) if keys.length > 0
      end
    end
    puts
    puts screen.to_s
  end
end

class TestBdfExample < Test::Unit::TestCase
  def setup
    @bdf = Bdf.load(TEST_FILE_EXAMPLE1)
  end

  def test_load_j
    expected = "j
░░░░░░░░░
░░░░░░░░░
░░░░░░███
░░░░░░███
░░░░░░███
░░░░░░███
░░░░░░░░░
░░░░░███░
░░░░░███░
░░░░░███░
░░░░░███░
░░░░███░░
░░░░███░░
░░░░███░░
░░░░███░░
░░░░███░░
░░░███░░░
░░░███░░░
░░░███░░░
░░░███░░░
░░████░░░
░████░░░░
████░░░░░
███░░░░░░
x: 8, y: 23"
    bbx = @bdf.bounding_box
    assert_equal expected, @bdf.char_to_s(:j, 0, bbx[:y] - 1)
  end

  def test_load_quoteright
    expected = "quoteright
░░░░░███░
░░░░░███░
░░░░░███░
░░░░░██░░
░░░░███░░
░░░░██░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
░░░░░░░░░
x: 5, y: 23"
    bbx = @bdf.bounding_box
    assert_equal expected, @bdf.char_to_s(:quoteright, 0, bbx[:y] - 1)
  end
end

