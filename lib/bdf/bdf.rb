require_relative 'reader'

module Bdf
  def self.load file
    Bdf::Reader.new(file).load
  end
end
