require 'vagrant/util/template_renderer'

module VagrantPlugins
  module Seil
    class Guest < Vagrant.plugin("2", :guest)
      def detect?(machine)
        machine.communicate.execute("show system")
      end
    end
  end
end
