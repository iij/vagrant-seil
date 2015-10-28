module VagrantPlugins
  module Seil
    module Cap
      class RemovePublicKey
        def self.remove_public_key(machine, contents)
          machine.communicate.tap do |comm|
            keytype, pubkey = contents.split.first(2)
            name = nil

            comm.execute("show config sshd") do |type, text|
              if type == :stdout
                if text =~ /^sshd authorized-key admin add (\S+) (\S+) (\S+)/
                  if keytype == $2 and pubkey == $3
                    name = $1
                  end
                end
              end
            end
            if name
              comm.execute("sshd authorized-key admin delete #{name}")
            end
          end
        end
      end
    end
  end
end
