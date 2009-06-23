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

require 'adhearsion/component_manager/spec_framework'

VOICEMAIL = ComponentTester.new("voicemail", File.dirname(__FILE__) + "/../..")

describe "Incoming calls" do
  before :each do
    @caller_id = "4085059096"
  end

  it "should identify the user associated with the caller ID" do
    callee = User.find_by_caller_id(@caller_id)
    callee.should_not be_nil
  end

  it "should locate the file uri for the latest vm greeting for the located user" do
    callee = User.find_by_caller_id(@caller_id)
    latest_status = callee.latest_status
    latest_status.should_not be_nil
    latest_status.class.name.should == VoiceStatus.new.class.name
    recording = latest_status.recording
    recording.should_not be_nil
    fn = recording.filename
    File.exists?(fn).should be_true
  end
end
