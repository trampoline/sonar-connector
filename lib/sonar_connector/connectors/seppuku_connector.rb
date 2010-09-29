module Sonar
  module Connector
    
    ## 
    # Suicide connector.Submits a command to cause the death of the entire connector framework. 
    # The connector will then get restarted by god or by the Windows service wrapper.
    # This ensures that the framework recovers honourably from unforseen hangs and crashes.
    class SeppukuConnector < Sonar::Connector::Base
      
      attr_accessor :enabled
      attr_accessor :run_count
      
      def parse(config)
        @enabled = config["enabled"] == true
        @run_count = 0
      end
      
      def action
        
        if !@enabled 
          log.debug "Config option must be explicitly set in order to commit Seppuku."
        elsif @run_count > 0 
          log.info "切腹! #{name} committing honourable suicide and terminating the connector framework."
          queue << Sonar::Connector::CommitSeppukuCommand.new
        end
        
        @run_count += 1
      end
      
    end
  end
end
