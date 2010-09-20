module Sguil
  class UI
    include Sguil::Helpers::UI

    def info(message)
      show_message :INFO, "#{message}", STDOUT
    end
    
    def verbose(message)
      show_message :VERBOSE, "#{message}", STDOUT
    end

    def debug(message)
      show_message :DEBUG, "#{message}", STDOUT
    end

    def warning(message)
      show_message :WARN, "#{message}", STDOUT
    end

    def error(message)
      show_message :ERROR, "#{message}", STDERR
    end

    def explicit(msg)
      STDOUT.puts red("#{msg}")
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
