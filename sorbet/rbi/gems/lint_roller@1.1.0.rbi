# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `lint_roller` gem.
# Please instead update this file by running `bin/tapioca gem lint_roller`.

# source://lint_roller//lib/lint_roller/version.rb#1
module LintRoller; end

# source://lint_roller//lib/lint_roller/about.rb#2
class LintRoller::About < ::Struct
  # Returns the value of attribute description
  #
  # @return [Object] the current value of description
  def description; end

  # Sets the attribute description
  #
  # @param value [Object] the value to set the attribute description to.
  # @return [Object] the newly set value
  def description=(_); end

  # Returns the value of attribute homepage
  #
  # @return [Object] the current value of homepage
  def homepage; end

  # Sets the attribute homepage
  #
  # @param value [Object] the value to set the attribute homepage to.
  # @return [Object] the newly set value
  def homepage=(_); end

  # Returns the value of attribute name
  #
  # @return [Object] the current value of name
  def name; end

  # Sets the attribute name
  #
  # @param value [Object] the value to set the attribute name to.
  # @return [Object] the newly set value
  def name=(_); end

  # Returns the value of attribute version
  #
  # @return [Object] the current value of version
  def version; end

  # Sets the attribute version
  #
  # @param value [Object] the value to set the attribute version to.
  # @return [Object] the newly set value
  def version=(_); end

  class << self
    def [](*_arg0); end
    def inspect; end
    def keyword_init?; end
    def members; end
    def new(*_arg0); end
  end
end

# source://lint_roller//lib/lint_roller/context.rb#2
class LintRoller::Context < ::Struct
  # Returns the value of attribute engine
  #
  # @return [Object] the current value of engine
  def engine; end

  # Sets the attribute engine
  #
  # @param value [Object] the value to set the attribute engine to.
  # @return [Object] the newly set value
  def engine=(_); end

  # Returns the value of attribute engine_version
  #
  # @return [Object] the current value of engine_version
  def engine_version; end

  # Sets the attribute engine_version
  #
  # @param value [Object] the value to set the attribute engine_version to.
  # @return [Object] the newly set value
  def engine_version=(_); end

  # Returns the value of attribute rule_format
  #
  # @return [Object] the current value of rule_format
  def rule_format; end

  # Sets the attribute rule_format
  #
  # @param value [Object] the value to set the attribute rule_format to.
  # @return [Object] the newly set value
  def rule_format=(_); end

  # Returns the value of attribute runner
  #
  # @return [Object] the current value of runner
  def runner; end

  # Sets the attribute runner
  #
  # @param value [Object] the value to set the attribute runner to.
  # @return [Object] the newly set value
  def runner=(_); end

  # Returns the value of attribute runner_version
  #
  # @return [Object] the current value of runner_version
  def runner_version; end

  # Sets the attribute runner_version
  #
  # @param value [Object] the value to set the attribute runner_version to.
  # @return [Object] the newly set value
  def runner_version=(_); end

  # Returns the value of attribute target_ruby_version
  #
  # @return [Object] the current value of target_ruby_version
  def target_ruby_version; end

  # Sets the attribute target_ruby_version
  #
  # @param value [Object] the value to set the attribute target_ruby_version to.
  # @return [Object] the newly set value
  def target_ruby_version=(_); end

  class << self
    def [](*_arg0); end
    def inspect; end
    def keyword_init?; end
    def members; end
    def new(*_arg0); end
  end
end

# source://lint_roller//lib/lint_roller/error.rb#2
class LintRoller::Error < ::StandardError; end

# source://lint_roller//lib/lint_roller/plugin.rb#2
class LintRoller::Plugin
  # `config' is a Hash of options passed to the plugin by the user
  #
  # @return [Plugin] a new instance of Plugin
  #
  # source://lint_roller//lib/lint_roller/plugin.rb#4
  def initialize(config = T.unsafe(nil)); end

  # @raise [Error]
  #
  # source://lint_roller//lib/lint_roller/plugin.rb#8
  def about; end

  # `context' is an instance of LintRoller::Context provided by the runner
  #
  # @raise [Error]
  #
  # source://lint_roller//lib/lint_roller/plugin.rb#18
  def rules(context); end

  # `context' is an instance of LintRoller::Context provided by the runner
  #
  # @return [Boolean]
  #
  # source://lint_roller//lib/lint_roller/plugin.rb#13
  def supported?(context); end
end

# source://lint_roller//lib/lint_roller/rules.rb#2
class LintRoller::Rules < ::Struct
  # Returns the value of attribute config_format
  #
  # @return [Object] the current value of config_format
  def config_format; end

  # Sets the attribute config_format
  #
  # @param value [Object] the value to set the attribute config_format to.
  # @return [Object] the newly set value
  def config_format=(_); end

  # Returns the value of attribute error
  #
  # @return [Object] the current value of error
  def error; end

  # Sets the attribute error
  #
  # @param value [Object] the value to set the attribute error to.
  # @return [Object] the newly set value
  def error=(_); end

  # Returns the value of attribute type
  #
  # @return [Object] the current value of type
  def type; end

  # Sets the attribute type
  #
  # @param value [Object] the value to set the attribute type to.
  # @return [Object] the newly set value
  def type=(_); end

  # Returns the value of attribute value
  #
  # @return [Object] the current value of value
  def value; end

  # Sets the attribute value
  #
  # @param value [Object] the value to set the attribute value to.
  # @return [Object] the newly set value
  def value=(_); end

  class << self
    def [](*_arg0); end
    def inspect; end
    def keyword_init?; end
    def members; end
    def new(*_arg0); end
  end
end

# source://lint_roller//lib/lint_roller/support/merges_upstream_metadata.rb#2
module LintRoller::Support; end

# source://lint_roller//lib/lint_roller/support/merges_upstream_metadata.rb#3
class LintRoller::Support::MergesUpstreamMetadata
  # source://lint_roller//lib/lint_roller/support/merges_upstream_metadata.rb#4
  def merge(plugin_yaml, upstream_yaml); end
end

# source://lint_roller//lib/lint_roller/version.rb#2
LintRoller::VERSION = T.let(T.unsafe(nil), String)
