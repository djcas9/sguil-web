module Sguil
  
  def Sguil.callbacks
    @callbacks ||= []
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
    
    def add_callback(&block)
      Sguil.callbacks << block if block
    end
    
    def on_connect(&block)
      Sguil.on_connect << block if block
    end
    
    def on_disconnect(&block)
      Sguil.on_disconnect << block if block
    end
    
  end
  
end