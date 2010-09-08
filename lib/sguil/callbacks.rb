module Sguil
  
  def Sguil.callbacks
    @callbacks ||= []
  end
  
  def Sguil.before_receive_data
    @before_data_callbacks ||= []
  end
  
  def Sguil.on_connect
    @connect_callbacks ||= []
  end
  
  def Sguil.on_disconnect
    @disconnect_callbacks ||= []
  end
  
  module Callbacks
    
    class << self
      include Sguil::Helpers::UI
    end
    
    def before_receive_data(&block)
      Sguil.before_receive_data << block if block
    end
    
    def before_connect(&block)
      Sguil.on_connect << block if block
    end
    
    def before_disconnect(&block)
      Sguil.on_disconnect << block if block
    end
    
  end
  
end