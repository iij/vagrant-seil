require "log4r"

require Vagrant.source_root.join("plugins/communicators/ssh/communicator")

module VagrantPlugins
  module Seil
    class Communicator < VagrantPlugins::CommunicatorSSH::Communicator
      def initialize(machine)
        super
        @logger.info("SEIL: Communicator#initialize")
      end

      def ready?
        @logger.info("SEIL: Communicator#ready?")
        super
      end

      def execute(command, **opts, &block)
        @logger.info("SEIL: execute => command=#{command.inspect} opts=#{opts.inspect} block=#{block.inspect}")
        super
      end

      def from_stdin(command, text, **opts)
        @logger.debug("from_stdin: #{command}")
        connect do |connection|
          stdout = ""

          channel = connection.open_channel do |ch|
            ch.send_channel_request "shell" do |ch, _|
              ch.on_data do |ch, data|
                stdout << data
                #@logger.debug("stdout=#{stdout.inspect}")
                @logger.debug("stdout << #{data.inspect}")
                ch.eof! if stdout =~ /^00\h{6}: /
              end

              @logger.debug("SEIL: command=#{command}")
              ch.send_data "#{command.strip}\n"
              @logger.debug("SEIL: text=#{text}")
              ch.send_data "#{text.strip}\n"
              ch.send_data "."
            end
          end

          # Wait for the channel to complete
          begin
            channel.wait
          rescue Errno::ECONNRESET, IOError
            @logger.info(
              "SSH connection unexpected closed. Assuming reboot or something.")
              exit_status = 0
              pty = false
          rescue Net::SSH::ChannelOpenFailed
            raise Vagrant::Errors::SSHChannelOpenFail
          rescue Net::SSH::Disconnect
            raise Vagrant::Errors::SSHDisconnected
          end
        end
      end

      # XXX: Copied from SSH communicator (of Vagrant version 1.7.2)
      # Executes the command on an SSH connection within a login shell.
      def shell_execute(connection, command, **opts)
        @logger.info("SEIL: shell_execute command=#{command.inspect}")

        opts = {
          sudo: false,
          shell: nil
        }.merge(opts)

        sudo  = opts[:sudo]
        shell = opts[:shell]

        @logger.info("Execute: #{command} (sudo=#{sudo.inspect})")
        exit_status = nil

        # Determine the shell to execute. Prefer the explicitly passed in shell
        # over the default configured shell. If we are using `sudo` then we
        # need to wrap the shell in a `sudo` call.
        #shell_cmd = @machine.config.ssh.shell
        #shell_cmd = shell if shell
        #shell_cmd = "sudo -E -H #{shell_cmd}" if sudo
        shell_cmd = ""
        @logger.info("SEIL: shell_cmd=#{shell_cmd}")
        # connection is Net::SSH::Connection::Session

        # These variables are used to scrub PTY output if we're in a PTY
        pty = false
        pty_stdout = ""

        # Open the channel so we can execute or command
        channel = connection.open_channel do |ch|
          @logger.info("SEIL: @machine.config.ssh.pty=#{@machine.config.ssh.pty}")
          if @machine.config.ssh.pty
            ch.request_pty do |ch2, success|
              pty = success && command != ""

              if success
                @logger.debug("pty obtained for connection")
              else
                @logger.warn("failed to obtain pty, will try to continue anyways")
              end
            end
          end

          #ch.exec(shell_cmd) do |ch2, _|
          command = "exit" if command.strip == ""
          ch.exec(command) do |ch2, _|
            # Setup the channel callbacks so we can get data and exit status
            ch2.on_data do |ch3, data|
              # Filter out the clear screen command
              data = remove_ansi_escape_codes(data)
              @logger.debug("stdout: #{data}")
              data.gsub!(/^\h{8}: /, "")
              if pty
                pty_stdout << data
              else
                yield :stdout, data if block_given?
              end
            end

            ch2.on_extended_data do |ch3, type, data|
              # Filter out the clear screen command
              data = remove_ansi_escape_codes(data)
              @logger.debug("stderr: #{data}")
              yield :stderr, data if block_given?
            end

            ch2.on_request("exit-status") do |ch3, data|
              exit_status = data.read_long
              @logger.debug("Exit status: #{exit_status}")

              # Close the channel, since after the exit status we're
              # probably done. This fixes up issues with hanging.
              channel.close
            end

            # Set the terminal
            #ch2.send_data "export TERM=vt100\n"

            # Set SSH_AUTH_SOCK if we are in sudo and forwarding agent.
            # This is to work around often misconfigured boxes where
            # the SSH_AUTH_SOCK env var is not preserved.
            if @connection_ssh_info[:forward_agent] && sudo
              auth_socket = ""
              execute("echo; printf $SSH_AUTH_SOCK") do |type, data|
                if type == :stdout
                  auth_socket += data
                end
              end

              if auth_socket != ""
                # Make sure we only read the last line which should be
                # the $SSH_AUTH_SOCK env var we printed.
                auth_socket = auth_socket.split("\n").last.chomp
              end

              if auth_socket == ""
                @logger.warn("No SSH_AUTH_SOCK found despite forward_agent being set.")
              else
                @logger.info("Setting SSH_AUTH_SOCK remotely: #{auth_socket}")
                ch2.send_data "export SSH_AUTH_SOCK=#{auth_socket}\n"
              end
            end

            #ch2.send_data "#{command}\n".force_encoding('ASCII-8BIT')

            # Output the command. If we're using a pty we have to do
            # a little dance to make sure we get all the output properly
            # without the cruft added from pty mode.
            @logger.info("SEIL: pty = #{pty}")
            if pty
              data = "stty raw -echo\n"
              data += "export PS1=\n"
              data += "export PS2=\n"
              data += "export PROMPT_COMMAND=\n"
              data += "printf #{PTY_DELIM_START}\n"
              data += "#{command}\n"
              data += "exitcode=$?\n"
              data += "printf #{PTY_DELIM_END}\n"
              data += "exit $exitcode\n"
              data = data.force_encoding('ASCII-8BIT')
              ch2.send_data data
            else
              ch2.send_data "#{command}\n".force_encoding('ASCII-8BIT')
              # Remember to exit or this channel will hang open
              ch2.send_data "exit\n"
            end

            # Send eof to let server know we're done
            ch2.eof!
          end
        end

        begin
          keep_alive = nil

          if @machine.config.ssh.keep_alive
            # Begin sending keep-alive packets while we wait for the script
            # to complete. This avoids connections closing on long-running
            # scripts.
            keep_alive = Thread.new do
              loop do
                sleep 5
                @logger.debug("Sending SSH keep-alive...")
                connection.send_global_request("keep-alive@openssh.com")
              end
            end
          end

          # Wait for the channel to complete
          begin
            channel.wait
          rescue Errno::ECONNRESET, IOError
            @logger.info(
              "SSH connection unexpected closed. Assuming reboot or something.")
              exit_status = 0
              pty = false
          rescue Net::SSH::ChannelOpenFailed
            raise Vagrant::Errors::SSHChannelOpenFail
          rescue Net::SSH::Disconnect
            raise Vagrant::Errors::SSHDisconnected
          end
        ensure
          # Kill the keep-alive thread
          keep_alive.kill if keep_alive
        end

        # If we're in a PTY, we now finally parse the output
        if pty
          @logger.debug("PTY stdout: #{pty_stdout}")
          if !pty_stdout.include?(PTY_DELIM_START) || !pty_stdout.include?(PTY_DELIM_END)
            @logger.error("PTY stdout doesn't include delims")
            raise Vagrant::Errors::SSHInvalidShell.new
          end

          data = pty_stdout[/.*#{PTY_DELIM_START}(.*?)#{PTY_DELIM_END}/m, 1]
            @logger.debug("PTY stdout parsed: #{data}")
          yield :stdout, data if block_given?
        end

        # Return the final exit status
        return exit_status
      end
    end
  end
end
