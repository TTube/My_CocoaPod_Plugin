# !/usr/bin/env ruby

module Pod
    class Installer
        class PostInstallHooksContext

            attr_accessor :aggregate_targets
            version = Gem::Version.new(Pod::VERSION)
        
            # PostInstallHooksContext inherit BaseContext, just override `generate`
            def self.generate(sandbox, pods_project, aggregate_targets)
                context = super
                UI.info "- start generate hmap"
                context.aggregate_targets = aggregate_targets
                context
            end
        
        end
    end
  end
  