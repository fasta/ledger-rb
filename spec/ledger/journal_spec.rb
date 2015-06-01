require 'spec_helper'


include Ledger

describe Journal do

  describe ".parse_to_blocks" do
    it "should return an array of the blocks within the provided string" do
      blocks = Journal.parse_to_blocks(<<EoT
Block 1
Block 2
Block 3
EoT
)
      blocks.must_equal ["Block 1", "Block 2", "Block 3"]

      blocks = Journal.parse_to_blocks(<<EoT
Block 1
Block 2
  2.1
  2.2
Block 3
EoT
)
      blocks.must_equal ["Block 1", "Block 2\n  2.1\n  2.2", "Block 3"]
    end
  end

  describe ".parse" do
    it "should return the parsed Journal" do
      j = Journal.parse(<<EoT
2015/05/30 Description
  Account Amount
  Account
EoT
)
      j.transactions.count.must_equal 1
    end
  end

end