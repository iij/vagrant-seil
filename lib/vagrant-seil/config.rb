module VagrantPlugins
  module Seil
    class Config < Vagrant.plugin("2", :config)
      #attr_accessor :halt_timeout
      attr_accessor :config
      attr_accessor :function_key
      attr_accessor :starter_key

      def initialize
        @config       = UNSET_VALUE
        @function_key = UNSET_VALUE
        @starter_key  = UNSET_VALUE
      end

      def finalize!
        @config       = nil if @config == UNSET_VALUE
        @function_key = nil if @function_key == UNSET_VALUE
        @starter_key  = nil if @starter_key == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors

        { "SEIL provisioner" => errors }
      end
    end
  end
end
