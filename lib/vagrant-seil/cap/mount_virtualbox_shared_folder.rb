module VagrantPlugins
  module Seil
    module Cap
      class MountVirtualBoxSharedFolder
        def self.mount_virtualbox_shared_folder(machine, name, guestpath, options)
          machine.ui.detail I18n.t("vagrant_seil.no_synced_folders")
        end
      end
    end
  end
end
