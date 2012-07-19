class Key < ActiveRecord::Base
  
  # create a random-string with len chars
  def set_unique_random_key(len = 16)
    begin
      chars = ('a'..'z').to_a + ('A'..'Z').to_a
      self.key = (0..(len-1)).collect { chars[Kernel.rand(chars.length)] }.join
    end while Key.find_by_key(self.key)
  end    
end
