require 'tempfile'
require 'rspec/core/formatters/base_formatter'

class NexusFormatter < RSpec::Core::Formatters::BaseFormatter
  def initialize(output)
    super
    @file = Tempfile.new('nexus-output')
  end

  def stop
    failed_examples.each_with_index do |example, index|
      exception = example.execution_result[:exception]
      backtrace = format_backtrace(exception.backtrace, example)

      say "#{index.succ}) #{example.full_description}"
      backtrace.each { |line| say line }
    end

    @file.close

    vim "NexusQuickfix('rspec', '#{@file.path}')"
  end

  private

  def say(line)
    @file.puts line
  end

  def vim(command)
    %x{gvim --remote-expr "#{command}"}
  end
end

RSpec.configuration.add_formatter 'NexusFormatter'
