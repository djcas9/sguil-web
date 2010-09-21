module Sguil
  class Parse

    def initialize(data)
      @data = data
    end

    def new_snort_stats
      raw_data = strip_brackets(strip_brackets(@data))
      raw_data.to_s.split(/\} \{/).each do |insert|
        return build_sensor_data(insert)
      end
    end

    def user_message
      message = []
      user_message = chop_at('UserMessage')
      username = user_message.first
      user_message.collect { |word| message << word unless word == username }
      return { :username => username, :message => message.join(' ') }
    end

    def insert_system_information
      message = []
      system_message = chop_at('InsertSystemInfoMsg')
      system_object = system_message.first
      system_message.collect { |word| message << word unless word == system_object }
      return { :object => system_object, :message => message.join(' ') }
    end

    def insert_event
      build_event_data(@data)
    end

    def sensors
      Sguil.sensors = chop_at('SensorList')
    end

    def update_snort_stats
      update_sensor_data(strip_brackets(@data))
    end
    
    def increment_event
      data = @data.gsub('IncrEvent').split(' ')
      
      ids = data.split('.')
      
      incr_event = Hash.new
      incr_event.merge!(
        {
          :event_uid => data[0],
          :sensor_id => ids.first,
          :event_id => ids.last,
          :priority => data[1],
          :count => data[2]
      })
      
      incr_event
    end

    private

      def strip_brackets(data)
        return data[/\{(\S.+)\}/,1]
      end

      def chop_at(word)
        @data.to_s.gsub("#{word}", '').gsub(/\{|\}/, '').split(' ')
      end

      def build_sensor_data(data)
        sensor_data = Hash.new
        datetime = data[/\{(.+?)\}/,1]
        data = data.gsub(/\{(.+?)\}/, '').gsub('  ', ' ').split(' ')

        sensor_data.merge!(
          {
            :id => data[0],
            :name => data[1],
            :packet_loss => "#{data[2]}%",
            :avg_bw => "#{data[3]}MB/s",
            :alerts => "#{data[4]}/sec",
            :packets => "#{data[5]}/sec",
            :bytes => "#{data[6]}/pckt",
            :match => "#{data[7]}%",
            :new_ssns => "#{data[8]}/sec",
            :ttl_ssns => "#{data[9]}",
            :max_ssns => "#{data[10]}",
            :updated_at => datetime
        })
        sensor_data
      end

      def build_event_data(data)
        insert_event = Hash.new
        raw_data = data[/\{(\S.+)\}/,1]
        datetime = raw_data[/\{(.+?)\}/,1]
        sig_name = raw_data[/.+\{(.+?)\}/,1]
        if sig_name =~ /\} \{/
          sig_name = 'N/A'
        end
        data = raw_data.gsub(/\{(.+?)\}/, '').gsub('  ', ' ').split(' ')

        insert_event.merge!(
          {
            :priority => data[1],
            :sensor => data[3],
            :sensor_id => data[4],
            :event_id => data[5],
            :signature => sig_name,
            :source_ip => data[6],
            :source_port => data[9],
            :destination_ip => data[7],
            :destination_port => data[10],
            :generator_id => data[13],
            :signature_id => data[11],
            :signature_reference => data[15],
            :created_at => datetime,
        })
        insert_event
      end

  end
end