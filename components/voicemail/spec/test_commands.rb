module DialplanCommandTestHelpers
  def self.included(test_case)
    test_case.send(:attr_reader, :mock_call, :input, :output)

    test_case.before do
      @input      = MockSocket.new
      @output     = MockSocket.new
      @mock_call  = Object.new
      @mock_call.metaclass.send(:attr_reader, :call)
      mock_call.extend(Adhearsion::VoIP::Asterisk::Commands)
      flexmock(mock_call) do |call|
        call.should_receive(:from_pbx).and_return(input)
        call.should_receive(:to_pbx).and_return(output)
      end
    end
  end

  class MockSocket

    def print(message)
      messages << message
    end

    def read
      messages.shift
    end

    def gets
      read
    end

    def messages
      @messages ||= []
    end
  end


  private

  def should_pass_control_to_a_context_that_throws(symbol, &block)
    did_the_rescue_block_get_executed = false
    begin
      yield
    rescue Adhearsion::VoIP::DSL::Dialplan::ControlPassingException => cpe
      did_the_rescue_block_get_executed = true
      cpe.target.should.throw symbol
    rescue => e
      did_the_rescue_block_get_executed = true
      raise e
    ensure
      did_the_rescue_block_get_executed.should.be true
    end
  end

  def should_throw(sym=nil, &block)
    block.should.throw(*[sym].compact)
  end

  def mock_route_calculation_with(*definitions)
    flexmock(Adhearsion::VoIP::DSL::DialingDSL).should_receive(:calculate_routes_for).and_return(definitions)
  end

  def pbx_should_have_been_sent(message)
    output.gets.should.equal message
  end

  def pbx_should_respond_with(message)
    input.print message
  end

  def pbx_should_respond_with_digits(string_of_digits)
    pbx_should_respond_with "200 result=#{string_of_digits}"
  end

  def pbx_should_respond_with_digits_and_timeout(string_of_digits)
    pbx_should_respond_with "200 result=#{string_of_digits} (timeout)"
  end

  def pbx_should_respond_to_timeout(timeout)
    pbx_should_respond_with "200 result=#{timeout}"
  end

  def pbx_should_respond_with_value(value)
    pbx_should_respond_with "200 result=1 (#{value})"
  end

  def pbx_should_respond_with_success(success_code = nil)
    pbx_should_respond_with pbx_success_response(success_code)
  end

  alias does_not_read_data_back pbx_should_respond_with_success

  def pbx_should_respond_with_failure(failure_code = nil)
    pbx_should_respond_with(pbx_failure_response(failure_code))
  end

  def pbx_should_respond_with_successful_background_response(digit=0)
    pbx_should_respond_with_success digit.kind_of?(String) ? digit[0] : digit
  end

  def pbx_should_respond_with_a_wait_for_digit_timeout
    pbx_should_respond_with_successful_background_response 0
  end

  def pbx_success_response(success_code = nil)
    "200 result=#{success_code || default_success_code}"
  end

  def default_success_code
    '1'
  end

  def pbx_failure_response(failure_code = nil)
    "200 result=#{failure_code || default_failure_code}"
  end

  def default_failure_code
    '0'
  end

  def output_stream_matches(pattern)
    assert_match(pattern, output.gets)
  end

  module OutputStreamMatchers
    def pbx_was_asked_to_play(*audio_files)
      audio_files.each do |audio_file|
        output_stream_matches(/playback #{audio_file}/)
      end
    end

    def pbx_was_asked_to_play_number(number)
      output_stream_matches(/saynumber #{number}/)
    end

    def pbx_was_asked_to_play_time(number)
      output_stream_matches(/sayunixtime #{number}/)
    end

    def pbx_was_asked_to_execute(application, *options)
      output_stream_matches(/exec saydigits #{options.join('|')}/i)
    end
  end
  include OutputStreamMatchers

  def assert_success(response)
    response.should.equal pbx_success_response
  end

end


module MenuBuilderTestHelper
  def builder_should_match_with_these_quantities_of_calculated_matches(checks)
    checks.each do |check, hash|
      hash.each_pair do |method_name, intended_quantity|
        message = "There were supposed to be #{intended_quantity} #{method_name.to_s.humanize} calculated."
        builder.calculate_matches_for(check).send(method_name).
                should.messaging(message).equal(intended_quantity)
      end
    end
  end
end

module MenuTestHelper

  def pbx_should_send_digits(*digits)
    digits.each do |digit|
      digit = nil if digit == :timeout
      mock_call.should_receive(:interruptable_play).once.and_return(digit)
    end
  end
end

module ConfirmationManagerTestHelper
  def encode_hash(hash)
    Adhearsion::DialPlan::ConfirmationManager.encode_hash_for_dial_macro_argument(hash)
  end
end
