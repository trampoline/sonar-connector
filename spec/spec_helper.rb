$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sonar_connector'
require 'spec'
require 'spec/autorun'
require 'rr'


Spec::Runner.configure do |config|
  config.mock_with :rr
  
  
  config.append_before(:each) do
    # stub()
  end
end