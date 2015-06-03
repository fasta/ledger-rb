module Ledger
  class Posting
    attr_accessor :account, :amount

    def self.from_s(string)
      posting = Posting.new

      posting.account, posting.amount = string.split(/\s\s+/, 2).map {|e| e.strip }
      if posting.amount
        posting.amount = Amount.from_s(posting.amount)
      end

      posting
    end

  end
end
