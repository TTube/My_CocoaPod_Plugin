# !/usr/bin/env ruby


$generator_global_config = HMapGenratorConfig.new

# HMapGenerator全局配置
module HMapGenerator
    class HMapGenratorConfig
        def initialize
          # 不处理的pod列表
          @ignore_pod_list = []
          # 是否为主工程添加pod的hmap search path
          @add_hmap_to_main_project = false
        end

        def update_ignore_pod_list(list)
          if list != nil && list.size() > 0
            @ignore_pod_list.concat(list)
          end
        end

    end
end

module Pod
  class Podfile
      module DSL
        def hmap_generator_ignore(list)
          $generator_global_config.update_ignore_pod_list(list)
        end

        def main_project_pod_hmap_enable(enable)
          $generator_global_config.add_hmap_to_main_project = true
        end
      end  
  end
end
  