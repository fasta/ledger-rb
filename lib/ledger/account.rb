module Ledger
  class Account
    attr_accessor :name, :amounts, :alias
    attr_accessor :subaccounts

    def initialize(options={})
      @name = options[:name] || nil
      @amounts = options[:amounts] || []
      @subaccounts = options[:subaccounts] || []
      @alias = options[:alias] || nil
    end

    def total_amounts
      totals = subaccounts.map(&:total_amounts).flatten + amounts

      totals.reduce([]) do |total, amount|
        if not total.map(&:commodity).include?(amount.commodity)
          total << amount
        else
          total.map! {|t| (t.commodity == amount.commodity) ? t + amount : t }
        end

        total
      end
    end

    def self.organize(accounts)
      raise ArgumentError if accounts.map(&:name).uniq.count != accounts.count

      organized = []
      accounts.each do |account|

        a = account.name.split(':').reduce(nil) do |parent, child_name|
          child = Account.new(name: child_name)

          # If no parent is set, the Account name must be on the top level,
          # in which case it cannot be retrieved from the parents' subaccounts,
          # but may be retrieved from the array containing already organized
          # Accounts.
          if parent.nil?
            # Check if an Account with this name already exists. If not,
            # add a new Account for this name, else use the existing one.
            if c = organized.select {|o| o.name == child_name }.first
              child = c
            else
              organized << child
            end
          else
            # Check if an Account with this name already exists. If not,
            # add a new Account for this name, else use the existing one.
            if c = parent.subaccounts.select {|s| s.name == child_name }.first
              child = c
            else
              parent.subaccounts << child
            end
          end

          child
        end
        a.amounts = account.amounts

      end

      organized
    end

    def self.from_transactions(transactions)
      raise ArgumentError unless transactions.reject(&:complete?).empty?
      raise ArgumentError unless transactions.reject(&:balanced?).empty?

      transactions.reduce([]) do |accounts, tx|
        tx.postings.each do |p|
          account = accounts.select {|a| a.name == p.account_name }.first
          if account
            # Update total amount if commodity is already present
            account.amounts.map! do |a|
              (a.commodity == p.amount.commodity) ? a + p.amount : a
            end
            # Add commodity otherwise
            unless account.amounts.map(&:commodity).include?(p.amount.commodity)
              account.amounts << p.amount
            end
          else
            accounts << Account.new(name: p.account_name, amounts: [p.amount])
          end
        end

        accounts
      end
    end

    def self.from_s(string)
      lines = string.split("\n").map(&:strip)

      Account.new(:name => lines.first.split(' ', 2).last,
                  :alias => lines.map{|l| l[/alias (.*)/, 1] }.compact.first)
    end

    def ==(other)
      if name == other.name &&
         amounts == other.amounts &&
         subaccounts == other.subaccounts &&
         self.alias == other.alias    # self needed because alias is a ruby keyword
        true
      else
        false
      end
    end

  end
end
