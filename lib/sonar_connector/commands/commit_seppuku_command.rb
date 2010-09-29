module Sonar
  module Connector
    
    class CommitSeppukuCommand < Sonar::Connector::Command
      def initialize
        l = lambda do
          # controller is in scope here because we've jumped thru some serious hoops
          # and shaved the hell out of a yak or three.
          Thread.new {controller.shutdown_lambda.call}
        end
        super(l)
      end
    end
  end
end
