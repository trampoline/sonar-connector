module Sonar
  module Connector
    
    class CommitSeppukuCommand < Sonar::Connector::Command
      def initialize
        l = ->(_) {
          # controller is in scope here because we've jumped thru some serious hoops
          # and shaved the hell out of a yak or three.
          Thread.new {controller.shutdown_lambda.call}
        }
        super(l)
      end
    end
  end
end
