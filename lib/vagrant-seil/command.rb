require "optparse"
require "vagrant"

module VagrantPlugins
  module Seil
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        "save configuration of running SEIL into specified host file"
      end

      def execute
        options = {}

        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant seil-save-to [options] [name]"
          o.separator ""
          o.separator "Options:"
          o.separator ""

          o.on("-o", "--output FILENAME", "Save a SEIL configuration in specified file") do |v|
            options[:output] = v
          end
        end

        argv = parse_options(opts)

        with_target_vms(argv, simgle_target: true) do |vm|
          if options[:output] == nil
            vm.ui.warn I18n.t("vagrant_seil.save_to_failed")
            return
          end

          lines = ""
          vm.communicate.tap do |comm|
            comm.execute("show config") do |type, text|
              lines += text
            end
          end

          begin
            File.open(options[:output], "w") do |f|
              lines.split("\r\n").each do |line|
                # remove unnecessary lines
                case line
                when /^success$/
                  next
                when /^exit\(\d+\)\.$/
                  next
                end

                f.puts(line)
              end
            end
          rescue
            vm.ui.warn I18n.t("vagrant_seil.save_to_failed")
            return
          end

          return 0
        end
      end
    end
  end
end
