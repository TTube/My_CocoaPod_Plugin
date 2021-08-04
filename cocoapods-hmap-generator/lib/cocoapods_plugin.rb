# !/usr/bin/env ruby
require 'cocoapods-hmap-generator/podfile_config'
require 'cocoapods-hmap-generator/target_config'
require 'cocoapods-hmap-generator/post_install_hook'
require 'cocoapods-hmap-generator/hmap_generator_core'

def analyze_depend_target(depend_t, creator, generate_type)
  depend_t.dependent_targets.each do |depend_target|
    # set public header for dependent target
    hmap.add_hmap_with_header_mapping(depend_target.header_mappings_by_file_accessor, generate_type, depend_target.name)
    analyze_depend_target(depend_target, hmap, generate_type)
  end
end

module HMapGenerator
  Pod::HooksManager.register('cocoapods-hmap-generator', :post_install) do |post_context|

    generate_type = HmapCreator::BOTH
    hmaps_dir = post_context.sandbox_root +  '/prebuilt-hmaps'
    unless File.exist?(hmaps_dir)
        Dir.mkdir(hmaps_dir)
    end

    post_context.aggregate_targets.each do |one|
      creator = HmapCreator.new
      ignore_pod_list = $generator_global_config.ignore_pod_list
      one.pod_targets.each do |target|
        Pod::UI.info "- creating headers map of target :#{target.name}"
        creator.add_hmap_with_header_mapping(target.public_header_mappings_by_file_accessor, generate_type, target.name)
        unless ignore_pod_list.include?(target.name)
          target_hmap_creator = HmapCreator.new
          # set project header for current target
          target_hmap_creator.add_hmap_with_header_mapping(target.header_mappings_by_file_accessor, HmapCreator::BOTH, target.name)

          analyze_depend_target(target, target_hmap_creator, generate_type)
          # target.dependent_targets.each do |depend_target|
          #   # set public header for dependent target
          #   target_hmap_creator.add_hmap_with_header_mapping(depend_target.public_header_mappings_by_file_accessor, generate_type, depend_target.name)
          # end

          target_hmap_name="#{target.name}.hmap"
          target_hmap_path = hmaps_dir + "/#{target_hmap_name}"
          relative_hmap_path = "prebuilt-hmaps/#{target_hmap_name}"
          if target_hmap_creator.save_to(target_hmap_path)
            target.reset_target_search_path_with_hmap_path(relative_hmap_path)
          end
        else
          Pod::UI.info "- skip handling headers of target :#{target.name}"
        end
      end

      pods_hmap_name = "#{one.name}.hmap"
      pods_hmap_path = hmaps_dir + "/#{pods_hmap_name}"
      relative_hmap_path = "prebuilt-hmaps/#{pods_hmap_name}"
      if $generator_global_config.add_hmap_to_main_project
        if pods_hmap.save_to(pods_hmap_path)
            # override xcconfig
            one.reset_target_search_path_with_hmap_path(relative_hmap_path)
          end
      end
      
    end
  end
end
