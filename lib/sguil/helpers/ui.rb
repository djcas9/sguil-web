module Sguil
  module Helpers
    module UI
      
      #
      # Green
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Green Colored String
      #
      def green(msg)
        "\e[32m#{msg}\e[0m"
      end

      #
      # Yellow
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Yellow Colored String
      #
      def yellow(msg)
        "\e[33m#{msg}\e[0m"
      end
      
      #
      # Blue
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Blue Colored String
      #
      def blue(msg)
        "\e[34m#{msg}\e[0m"
      end

      #
      # Red
      #
      # @param [String] msg Message to format.
      #
      # @return [String] Red Colored String
      #
      def red(msg)
        "\e[31m#{msg}\e[0m"
      end

      #
      # Basename
      #
      # @param [String] path Path to extract the basename from
      #
      # @return [Object] Pathname Object
      #
      def basename(path)
        Pathname.new(path).basename
      end

      #
      # Parent Name
      #
      # @param [String] path Path to extract the parent folder name from
      #
      # @return [String] Parent Folder Name
      #
      def parent(path)
        Pathname.new(path).parent
      end

      #
      # Empty Folder?
      #
      # @param [String] folder Path to folder
      #
      # @return [true,false] Return true if the folder is empty.
      #
      def folder_empty?(folder)
        if File.exists?(folder)
          return true unless Dir.enum_for(:foreach, folder).any? {|n| /\A\.\.?\z/ !~ n}
          return false
        else
          return false
        end
      end

      # Prompt the use for input
      #
      # @param [String] msg
      #  Message to prompt for user input.
      #
      # @param [Hash] options
      #
      # @option options [Symbol, String] :default
      #   The default option for a return.
      #
      def ask(msg, options={})
        default = options[:default] || false

        if default
          STDOUT.print "#{green("INFO")} #{msg} [Y/n] "
        else
          STDOUT.print "#{green("INFO")} #{msg} [y/N] "
        end
        input = STDIN.gets.chomp
        STDOUT.flush

        if block_given?
          if input[/([Yy]|[Yy]es)$/i]
            yield
          elsif input[/([Nn]|[Nn]o)$/i]
            return
          else
            yield if default
          end
        end
      end
      
    end
  end
end