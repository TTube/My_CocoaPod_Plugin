# !/usr/bin/env ruby

module Xcodeproj
    class Config

        def remove_attr(key)
            if key != nil
            @attributes.delete(key)
            end
        end

        def remove_search_path(condition)
            header_search_paths = @attributes['HEADER_SEARCH_PATHS']
            if header_search_paths
                new_paths = Array.new
                header_search_paths.split(' ').each do |p|
                    #不将命中条件的内容添加到new_paths中
                    if !condition(p)
                        new_paths << p
                    end
                end
                if new_paths.size > 0
                    @attributes['HEADER_SEARCH_PATHS'] = new_paths.join(' ')
                else
                    remove_attr('HEADER_SEARCH_PATHS')
                end
            end
        end

        # 移除 cocoapods 生成的 ${PODS_ROOT}/Headers search path
        def remove_pod_origin_search_path
            pod_search_path_match = Proc.new do |dist, *args|
                search_path = args.first
                if search_path.include?('${PODS_ROOT}/Headers')
                    return true
                end
                return false
            end
            remove_search_path(pod_search_path_match)
        end

        # 移除重复的hmap路径
        def remove_duplicative_hmap_path(hmap_path)
            hmap_path_match = Proc.new do |dist, *args|
                search_path = args.first
                if search_path.include?(hmap_path)
                    return true
                end
                return false
            end
            remove_search_path(hmap_path_match)
        end

        # 移除 <Module/Header.h> 的搜索路径
        def remove_system_option_in_other_cflags
            flags = @attributes['OTHER_CFLAGS']
            if flags
                new_flags = ''
                skip = false
                flags.split(' ').each do |substr|
                    if skip
                        skip = false
                        next
                    end
                    if substr == '-isystem'
                        skip = true
                        next
                    end
                    if new_flags.length > 0
                        new_flags += ' '
                    end
                    new_flags += substr
                end
                if new_flags.length > 0
                    @attributes['OTHER_CFLAGS'] = new_flags
                else
                    remove_attr('OTHER_CFLAGS')
                end
            end
        end


        def reset_header_search_path_to_hmap(hmap_path)
            # remove all search paths
            remove_pod_origin_search_path
            remove_duplicative_hmap_path(hmap_path)
            remove_system_option_in_other_cflags

            # add build flags
            new_paths = Array["${PODS_ROOT}/#{hmap_path}"]
            header_search_paths = @attributes['HEADER_SEARCH_PATHS']
            if header_search_paths
                new_paths.concat(header_search_paths.split(' '))
            end
            @attributes['HEADER_SEARCH_PATHS'] = new_paths.join(' ')
        end

        def set_use_hmap(use=false)
            @attributes['USE_HEADERMAP'] = (use ? 'YES' : 'NO')
        end
    end
    
  end
  