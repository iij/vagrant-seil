require "log4r"
require "vagrant"

module VagrantPlugins
  module Seil
    class Plugin < Vagrant.plugin("2")
      name "SEIL/x86 guest"
      description "SEIL/x86 guest support."

      guest("seil")  do
        require File.expand_path("../guest", __FILE__)
        Guest
      end

      #guest_capability("seil", "change_host_name") do
      #  require_relative "cap/change_host_name"
      #  Cap::ChangeHostName
      #end

      guest_capability("seil", "mount_virtualbox_shared_folder") do
        require_relative "cap/mount_virtualbox_shared_folder"
        Cap::MountVirtualBoxSharedFolder
      end

      config(:seil, :provisioner)  do
        require_relative "config"
        Config
      end

      provisioner "seil" do
        setup_i18n
        #setup_logging

        require_relative "provisioner"
        Provisioner
      end

      communicator(:seil_ssh) do
        require_relative "communicator"
        Communicator
      end

      guest_capability("seil", "configure_networks") do
        require_relative "cap/configure_networks"
        Cap::ConfigureNetworks
      end

      guest_capability("seil", "insert_public_key") do
        require_relative "cap/insert_public_key"
        Cap::InsertPublicKey
      end

      guest_capability("seil", "remove_public_key") do
        require_relative "cap/remove_public_key"
        Cap::RemovePublicKey
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path("locales/en.yml", Seil.source_root)
        I18n.reload!
      end

      #action_hook(:install_keys, Plugin::ALL_ACTIONS) do |hook|
      #  require_relative "action/install_keys"
      #  hook.before(Vagrant::Action::Builtin::Provision, Action::InstallKeys)
      #end

      # guest_capability("freebsd", "halt") do
      #   require_relative "cap/halt"
      #   Cap::Halt
      # end

      # guest_capability("freebsd", "mount_nfs_folder") do
      #   require_relative "cap/mount_nfs_folder"
      #   Cap::MountNFSFolder
      # end
    end
  end
end
