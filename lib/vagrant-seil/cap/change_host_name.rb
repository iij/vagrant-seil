module VagrantPlugins
  module Seil
    module Cap
      class ChangeHostName
        def self.change_host_name(machine, name)
          #machine.communicate.execute("hostname #{name}")
          true
        end
      end
    end
  end
end
