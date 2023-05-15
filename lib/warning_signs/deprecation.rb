module WarningSigns
  class Deprecation
    attr_accessor :message, :source, :category, :backtrace

    def initialize(message, source:, category: nil, backtrace: [])
      @message = message
      @source = source.to_s.downcase.inquiry
      @category = category
      @backtrace = backtrace || []
    end

    def handler
      World.instance.handler_for(self)
    end

    # force raise to be the last element if it is present
    def behaviors
      result = (handler&.environment&.behaviors || []).inquiry
      return result unless result.raise?
      (result - ["raise"]) << "raise"
    end

    def backtrace_lines
      lines = handler&.backtrace_lines || 0
      backtrace[1..lines]
    end

    def invoke
      behaviors.each do |behavior|
        case behavior
        when "raise"
          raise UnhandledDeprecationError, message
        when "log"
          Rails.logger.warn({ message: message, backtrace: backtrace_lines.map(&:to_s) })
        when "stderr"
          $stderr.puts(message) # standard:disable Style/StderrPuts
          $stderr.puts(backtrace_lines) # standard:disable Style/StderrPuts
        when "stdout"
          $stdout.puts(message) # standard:disable Style/StdoutPuts
          $stdout.puts(backtrace_lines) # standard:disable Style/StdoutPuts
        end
      end
    end
  end
end
