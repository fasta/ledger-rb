require 'spec_helper'


include Ledger

describe Journal do

  describe "#initialize" do
    it "should return a Journal initialized with the given options or nil" do
      j = Journal.new
      j.transactions.must_equal []
      j.accounts.must_equal []

      j = Journal.new(transactions: ['Transaction'], accounts: ['Account'])
      j.transactions.must_equal ['Transaction']
      j.accounts.must_equal ['Account']
    end
  end

  describe "#valid?" do
    it "should return false if the Journal contains unbalanced Transactions" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Account A'),
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-5.00')])])

      j.valid?.must_equal false
    end

    it "should return false if the Journal contains Transactions with undefined Accounts" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')])])

      j.valid?.must_equal false
    end

    it "should return true if the Journal's Transactions are balanced and its Accounts defined" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Account A'),
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')])])

      j.valid?.must_equal true
    end
  end

  describe ".parse_to_blocks" do
    it "should return a Hash of the blocks within the provided string with the line number as key" do
      blocks = Journal.parse_to_blocks(<<EoT
Block 1
Block 2
Block 3
EoT
)
      blocks.must_equal({ 1 => "Block 1", 2 => "Block 2", 3 => "Block 3" })

      blocks = Journal.parse_to_blocks(<<EoT
Block 1
Block 2
  2.1
  2.2
Block 3
EoT
)
      blocks.must_equal({ 1 => "Block 1", 2 => "Block 2\n  2.1\n  2.2", 5 => "Block 3" })
    end
  end

  describe ".parse" do
    it "should return the parsed Journal" do
      j = Journal.parse(<<EoT
account Account
  alias A

2015/05/30 Description
  Account   $1
  Account
EoT
)
      j.transactions.count.must_equal 1
      j.transactions.first.line_nr.must_equal 4
      j.accounts.count.must_equal 1
    end
  end

end
