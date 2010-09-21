module Sguil
  class UI
    include Sguil::Helpers::UI
    
    LOGGERS = [:DEBUG, :VERBOSE, :INFO, :WARN, :ERROR]
    
    def logger(loggers)
      loggers.each do |log|
        const_name = "#{log}".upcase
        
        if Sguil::UI::LOGGERS.include?(const_name.to_sym)
           Sguil::UI.const_set(const_name.to_sym, true)
        else
          Sguil.ui.error("Unknown Logger #{const_name}\nAvailable Logger Options: #{Sguil::UI::LOGGERS.inspect}")
        end
        
      end
    end

    def info(message)
      show_message :INFO, "#{message}", STDOUT if configured(:INFO)
    end
    
    def verbose(message)
      show_message :VERBOSE, "#{message}", STDOUT if configured(:VERBOSE)
    end

    def debug(message)
      show_message :DEBUG, "#{message}", STDOUT if configured(:DEBUG)
    end

    def warning(message)
      show_message :WARN, "#{message}", STDOUT if configured(:WARN)
    end

    def error(message)
      show_message :ERROR, "#{message}", STDERR
    end

    def explicit(msg)
      STDOUT.puts red("#{msg}")
    end

    def configured(const)
      if Sguil::UI.const_defined?(const)
        return Sguil::UI.const_get(const)
      else
        return false
      end
    end

    def show_message(type,message,std)
      case type
      when :INFO
        type = green(type)
      when :WARN
        type = yellow(type)
      when :ERROR
        type = red(type)
      when :DEBUG
        type = green(type)
      when :VERBOSE
        type = blue(type)
      end
      
      message.split("\n").each do |msg|
        std.puts("#{type}: #{msg}") if std.respond_to?(:puts)
      end
      
    end

  end
end
