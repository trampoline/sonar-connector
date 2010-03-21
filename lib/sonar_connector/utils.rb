module Sonar
  module Connector
    module Utils
      
      #
      # Disk usage utility. Returns amount of disk space 
      # used in a given folder, in bytes.
      def du(dir)
        raise "#{dir} is not a directory" unless File.directory?(dir)
        glob = File.join(dir, "**", "*")
        Dir[glob].map {|f|
          File.read(f).size rescue nil
        }.compact.sum
      end
      
      module_function :du
    end
  end
end