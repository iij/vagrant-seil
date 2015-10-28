require "ipaddr"
require "vagrant/util/template_renderer"

module VagrantPlugins
  module Seil
    class Provisioner < Vagrant.plugin("2", :provisioner)
      def provision
        @machine.communicate.tap do |comm|
          if config.starter_key
            comm.from_stdin("install-key from stdin", config.starter_key)
          end

          if config.function_key
            comm.from_stdin("install-key from stdin", config.function_key)
          end

          if config.config
            hostname = @machine.config.vm.hostname || "vagrant"
            header = "hostname #{hostname}\n"
            header += <<-EOS
            interface lan0 add dhcp
            encrypted-password admin *
            encrypted-password user *
            EOS

            # [:private_network,
            #  {:ip=>"192.168.50.254",
            #   :protocol=>"tcp",
            #   :id=>"83fe7d32-3e29-63b1-7f24-4c3b9a42839c"}]
            ifidx = 1
            @machine.config.vm.networks.each { |type, netopts|
              next if type != :public_network && type != :private_network

              ifname = "lan#{ifidx}"
              ifidx += 1
              addr = netopts[:ip]
              if netopts[:netmask]
                plen = IPAddr.new(netopts[:netmask]).to_i.to_s(2).count("1")
              else
                plen = 24
              end
              header += "interface #{ifname} add #{addr}/#{plen}\n"
            }

            comm.execute("show config sshd") do |type, text|
              header << text if type == :stdout
            end

            text = header + config.config
            text.gsub!(/^ +/, "")
            text.gsub!(/ +$/, "")

            @machine.ui.detail I18n.t("vagrant_seil.load_from")
            comm.from_stdin("load-from stdin", text)

            saved = false
            comm.execute("show key") do |type, text|
              if type == :stdout and text.include? "Function Key"
                @machine.ui.detail I18n.t("vagrant_seil.save_to_flashrom")
                comm.execute("save-to flashrom")
                saved = true
              end
            end
            unless saved
              @machine.ui.warn I18n.t("vagrant_seil.not_saved")
            end
          end
        end
      end
    end
  end
end
