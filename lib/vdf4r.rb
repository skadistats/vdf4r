pwd = File.dirname(__FILE__)

Dir[File.join(pwd, 'vdf4r', '*.rb')].each {|file| require file }
