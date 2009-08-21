unless defined? Adhearsion
  if File.exists? File.dirname(__FILE__) + "/../../../adhearsion/lib/adhearsion.rb"
    # If you wish to freeze a copy of Adhearsion to this app, simply place a copy of Adhearsion
    # into a folder named "adhearsion" within this app's main directory.
    require File.dirname(__FILE__) + "/../../../adhearsion/lib/adhearsion.rb"
  elsif File.exists? File.dirname(__FILE__) + "/../../../../../../lib/adhearsion.rb"
    # This file may be ran from the within the Adhearsion framework code (before a project has been generated)
    require File.dirname(__FILE__) + "/../../../../../../lib/adhearsion.rb"
  else
    require 'rubygems'
    gem 'adhearsion', '>= 0.7.999'
    require 'adhearsion'
  end
end

ENV["RAILS_ENV"] ||= 'development'
require "/Users/zlu/projects/teresa/config/environment" unless defined?(RAILS_ROOT)

require 'adhearsion/component_manager'
require 'adhearsion/component_manager/spec_framework'

VOICEMAIL = ComponentTester.new("voicemail", File.dirname(__FILE__) + "/../..")

describe "Incoming calls" do

  include UglyHack

  before :each do
    mock_component_config_with({})
    @dialplan = new_dialplan_object # This should be handled by ComponentTester stuff.
    @user = User.find_or_create_by_phone_number :phone_number => "16502437867"
  end

  describe "handle_voicemail" do
    
    describe "when a call comes in from FlowRoute with the extension 14155340223 and an RDNIS is given" do
      it "should execute play_user_voicemails" do
        mock(@dialplan).extension { 14155340223 }.times(any_times)
        mock(@dialplan).rdnis { "" }.times(any_times)
        mock(@dialplan).callerid { "12223334444" }.times(any_times)
        mock(@dialplan).play_user_voicemails
        @dialplan.handle_voicemail
      end
    end
    
    describe "when a call comes in from FlowRoute with the extension 14155340223 and *no* RDNIS is given" do
      it "should execute play_voicemail_greeting" do
        mock(@dialplan).extension { 14155340223 }.times(any_times)
        mock(@dialplan).rdnis { "???" }.times(any_times)
        mock(@dialplan).callerid { "12223334444" }.times(any_times)
        mock(@dialplan).play_voicemail_greeting
        @dialplan.handle_voicemail
      end
    end
    
  end
  
  describe "greeting" do
    
    it "should sleep for two seconds before playing the greeting" do
      stub(@dialplan).sleep(2) { throw :sleep_called }
      lambda do
        @dialplan.play_greeting(@user)
      end.should throw_symbol(:sleep_called)
    end
    
  end
  
end
BEGIN {
module UglyHack
  def new_dialplan_object
    returning Object.new do |dialplan|
      VOICEMAIL.component_module.metaclass.send(:instance_variable_get, :@metadata)[:scopes][:dialplan].each do |dialplan_scope|
        dialplan.extend Module.new(&dialplan_scope)
      end
    end
  end
end
}
__END__
it "should locate the file uri for the latest vm greeting for the located user" do
  callee = User.find_by_phone_number(@phone_number)
  latest_status = callee.latest_status
  latest_status.should be_kind_of(VoiceStatus)
  
  recording = latest_status.recording
  recording.should_not be_nil
  dir = Dir.open("/vol/recordings/greetings")
  fnames = []
  dir.each do |file_name|
    fnames << file_name.split(".")[0]
  end
  fn = recording.filename.split("/").last  
  fnames.compact.should include(fn)
end
# ~> -:2: undefined local variable or method `oof' for main:Object (NameError)
