require "spec"
require "../../src/pars3k"

include Pars3k

describe Pars3k::Parser do
  a = Parse.char 'a'
  b = Parse.char 'b'
  c = Parse.char 'c'

  describe "#map" do
    it "applies the transform to the parser output" do
      p = a.map &.to_s
      p.parse("a").should eq "a"
    end
    it "captures exception in the transform as a ParseError" do
      p = a.map { |_| raise Exception.new "oh no" }
      result = p.parse("a")
      result.should be_a ParseError
      result.message.should be "oh no"
    end
  end

  describe "#+" do
    it "sequences `self` with another parser" do
      p = a + b
      p.parse("a").should be_a ParseError
      p.parse("ab").should eq({'a', 'b'})
      p.parse("abc").should eq({'a', 'b'})
    end
    it "flattens the results when chaining" do
      p = a + b + c
      p.parse("abc").should eq({'a', 'b', 'c'})
    end
    it "returns a ParseError if any fail" do
      p = a + b + c
      p.parse("zbc").should be_a ParseError
      p.parse("azc").should be_a ParseError
      p.parse("abz").should be_a ParseError
    end
  end

  describe "#<<" do
    p = a << b
    it "returns the result of self if both parsers succeed" do
      p.parse("ab").should eq 'a'
    end
    it "returns a ParseError is self errors" do
      p.parse("bb").should be_a ParseError
    end
    it "returns a ParseError is other errors" do
      p.parse("aa").should be_a ParseError
    end
  end

  describe "#>>" do
    p = a >> b
    it "returns the result of other if both parsers succeed" do
      p.parse("ab").should eq 'b'
    end
    it "returns a ParseError is self errors" do
      p.parse("bb").should be_a ParseError
    end
    it "returns a ParseError is other errors" do
      p.parse("aa").should be_a ParseError
    end
  end

  describe "#|" do
    p = a | b
    it "returns the result if either parser succeeds" do
      p.parse("a").should eq 'a'
      p.parse("b").should eq 'b'
    end
    it "returns a ParseError if both fail" do
      p.parse("c").should be_a ParseError
    end
    it "allows chaining with a custom error message" do
      result = (p | "nope").parse "c"
      result.should be_a ParseError
      result.as(ParseError).message.should eq "nope"
    end
  end

  describe "#&" do
    it "succeeds when both succeed" do
      p = a & Parse.alphabet
      p.parse("a").should eq 'a'
    end
    it "returns a ParseError if either fail" do
      (a & b).parse("a").should be_a ParseError
      (b & a).parse("a").should be_a ParseError
    end
  end
end
