require "pathname"

require "vagrant-seil/plugin"
require "vagrant-seil/version"

module VagrantPlugins
  module Seil
    lib_path = Pathname.new(File.expand_path("../vagrant-seil", __FILE__))
    autoload :Errors, lib_path.join("errors")

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
