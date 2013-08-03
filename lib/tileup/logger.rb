require 'logger'
require 'ostruct'

module TileUp

  # Base logger class, subclass this, do not use directly.
  class TileUpLogger

    def self.sym_to_severity(sym)
      severities =  {
        :debug   => Logger::DEBUG,
        :info    => Logger::INFO,
        :warn    => Logger::WARN,
        :error   => Logger::ERROR,
        :fatal   => Logger::FATAL
      }
      severity = severities[sym] || Logger::UNKNOWN
    end

    # create logger set to given level
    # where level is a symbol (:debug, :info, :warn, :error, :fatal)
    # options may specifiy verbose, which will log more info messages
    def initialize(level, options)
      @severity = level
      default_options = {
        verbose: false
      }
      @options = OpenStruct.new(default_options.merge(options))
    end

    def level
      @level
    end

    def level=(severity)
      logger.level = TileUpLogger.sym_to_severity(severity)
    end

    # log an error message
    def error(message)
      # note, we always log error messages
      add(:error, message)
    end

    # log a regular message
    def info(message)
      add(:info, message)
    end

    def warn(message)
      add(:warn, message)
    end

    # log a verbose message
    def verbose(message)
      add(:info, message) if verbose?
    end

    private

    # add message to log
    def add(severity, message)
      severity = TileUpLogger.sym_to_severity(severity)
      logger.add(severity, message)
    end

    # is logger in verbose mode?
    def verbose?
      @options.verbose
    end

    # create or return a logger
    def logger
      @logger ||= create_logger
    end

    # subclasses should overwrite this method, creating what ever
    # logger they want to
    def create_logger
      raise "You should create your own `create_logger` method"
    end

  end

  # Log to console logger
  class ConsoleLogger < TileUpLogger
    private
    def create_logger
      @logger = Logger.new(STDOUT)
      @logger.formatter = Proc.new do |sev, time, prg, msg|
        "#{time.strftime('%H:%M:%S').to_s} => #{msg}\n"
      end
      @logger
    end
  end
end