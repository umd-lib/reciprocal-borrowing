require 'singleton'

# Logger for tracking application usage
class TransactionsLogger < Logger
  include Singleton

  def initialize
    super(Rails.root.join('log/transactions.log'))
    self.formatter = formatter
    self
  end

  # Prefixes timestamp
  def formatter
    proc do |_severity, time, _progname, msg|
      formatted_time = time.iso8601
      "[#{formatted_time}] #{msg.to_s.strip}\n"
    end
  end

  class << self
    delegate :error, :debug, :fatal, :info, :warn, :add, :log, to: :instance
  end
end
