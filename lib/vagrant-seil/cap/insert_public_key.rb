require "vagrant/util/shell_quote"

module VagrantPlugins
  module Seil
    module Cap
      class InsertPublicKey
        def self.insert_public_key(machine, contents)
          contents = contents.split.first(2).join(" ")
          contents = Vagrant::Util::ShellQuote.escape(contents, "'")
          machine.communicate.tap do |comm|
            comm.execute("sshd authorized-key admin add VAGRANT #{contents}")
          end
        end
      end
    end
  end
end
