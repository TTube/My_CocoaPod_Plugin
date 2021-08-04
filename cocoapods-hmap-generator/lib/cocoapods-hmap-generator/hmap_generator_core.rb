# !/usr/bin/env ruby

module HMapGenerator
    class HmapCreator
        # 只引入 PRIVATE 形式的，如 "Header.h"
        PRIVATE = 1 # 001
        # 只引入 Public形式的import，如 <PodA/Header.h>
        PUBLIC = 2 # 010
        # PUBLIC和PRIVATE形式的都引入
        BOTH = 3  # 011
        def initialize
            @hmap = Hash.new
        end

        # header_mapping : [Hash{FileAccessor => Hash}] Hash of file accessors by header mappings.
        def add_hmap(header_mapping, type, target_name=nil)
            header_mapping.each do |facc, headers|
                headers.each do |key, value|
                    value.each do |path|
                        path_name = Pathname.new(path)
                        file_name = path_name.basename.to_s
                        dir_name = path_name.dirname.to_s + '/'
                        # construct hmap hash info
                        path_hash = Hash['suffix' => file_name, 'prefix' => dir_name]
                        if type & PRIVATE > 0
                            # import with quote
                            @hmap[file_name] = path_hash
                        end
                        if type & PUBLIC > 0 && target_name != nil
                            # import with angle bracket
                            @hmap["#{target_name}/#{name}"] = path_hash
                        end
                    end
                end
            end
        end
        # @path : path/to/xxx.hmap
        # @return : succeed
        def save_to(path)
            if path != nil && @hmap.empty? == false
                path_name=Pathname(path)
                json_path=path_name.dirname.to_s + '/' + 'temp.json'
                # write hmap json to file
                File.open(json_path, 'w') { |file| file << @hmap.to_json }
                # json to hmap
                success=system("hmap convert #{json_path} #{path}")
                # delete json file
                File.delete(json_path)
                success
            else
              false
           end
        end
    end
end
  