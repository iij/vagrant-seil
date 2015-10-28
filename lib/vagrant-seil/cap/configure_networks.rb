require 'ipaddr'

module VagrantPlugins
  module Seil
    module Cap
      class ConfigureNetworks
        def self.configure_networks(machine, networks)
          # [{:type=>:static,
          #   :adapter_ip=>"192.168.50.1",
          #   :ip=>"192.168.50.2",
          #   :netmask=>"255.255.255.0",
          #   :auto_config=>true,
          #   :interface=>1},
          #  {:type=>:dhcp,
          #   :use_dhcp_assigned_default_route=>false,
          #   :auto_config=>true,
          #   :interface=>2}]
          machine.communicate.tap do |comm|
            networks.each { |net|
              if net[:type] == :static
                ifname = "lan#{net[:interface]}"
                addr   = net[:ip]
                plen   = IPAddr.new(net[:netmask]).to_i.to_s(2).count("1")
                comm.execute("interface #{ifname} address #{addr}/#{plen}")
              else
                machine.env.ui.warn "SEIL cannot have more than one DHCP interface"
              end
            }
          end
        end
      end
    end
  end
end
