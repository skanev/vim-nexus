require 'tempfile'
require 'rspec/core/formatters/base_formatter'

class NexusFormatter < RSpec::Core::Formatters::BaseFormatter
  def initialize(output)
    super
    @file = Tempfile.new('nexus-output')
  end

  def example_passed(example)
    super
    vim 'nexus#passed()'
  end

  def example_failed(example)
    super
    vim 'nexus#failed()'
  end

  def start(example_count)
    super
    vim "nexus#started(#{example_count})"
  end

  def stop
    vim 'nexus#finished()'

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
    %x{gvim --remote-send '<F3>'} # TODO Find a key to force redrawing (--remote-send <F3>)
  end
end

RSpec.configuration.add_formatter 'NexusFormatter'
