module Sonar
  module Connector
    
    # Suicide connector.Submits a command to cause the death of the entire connector framework. 
    # The connector will then get restarted by god or by the Windows service wrapper.
    class SeppukuConnector < Sonar::Connector::Base
      
      attr_accessor :run_count
      
      def parse(config)
        @run_count = 0
      end
      
      def action
        
        if @run_count > 0 
          log.info "切腹! #{name} committing honourable suicide and terminating the connector service."
          queue << Sonar::Connector::CommitSeppukuCommand.new
        end
        
        @run_count += 1
      end
      
    end
  end
end
