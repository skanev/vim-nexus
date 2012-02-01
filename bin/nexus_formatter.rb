require 'rspec/core/formatters/base_formatter'
require 'tempfile'

class NexusFormatter < RSpec::Core::Formatters::BaseFormatter
  def initialize(output)
    super
    @file = Tempfile.new('nexus-output')
  end

  def stop
    failed_examples.each_with_index do |example, index|
      exception = example.execution_result[:exception]
      backtrace = format_backtrace(exception.backtrace, example)

      say "" unless index.zero?
      say "(#{index + 1}) #{example.full_description}"
      say "  #{exception.class.name}: #{exception.message}"
      backtrace.each { |line| say line }
    end

    @file.close

    system %{mvim --remote-expr "NexusLoadQuickfix('#{@file.path}')"}
  end

  private
  
  def say(line)
    @file.puts line
  end
end
