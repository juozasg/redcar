module Redcar
  class Project
    # Purpose of this class is to have a menu that shows the 5 most recent opened directories
    # This way users can quickly go to directories they have recently opened, or use frequently
    class RecentDirectories
      MAX_LENGTH = 10
      
      # Create menus for recent directories
      def self.storage
        @storage ||= begin
          storage = Plugin::Storage.new('recent_directories')
          storage.set_default('list', [])
          storage
        end
      end
      
      def self.generate_menu(builder)
        directories = storage['list']
        directories.each do |dir|
          builder.item(File.basename(dir)) do
            begin
              Project.open_dir(dir) #currently throws error 'Not a directory: ...' if the directory doesn't exist
            rescue RuntimeError => error
              if error.to_s == 'Not a directory: ' + dir 
                remove_path(dir)
              else #Not the RuntimeError expected, rethrowing error
                raise error.to_s
              end
            end
          end
        end
      end
      
      # Stores the given path to the text file, to appear in the recent directories menu.
      #
      # @param [String] path  the path of a directory to be saved
      def self.store_path(path)
        path = File.expand_path(path)
        storage["list"].delete(path)
        storage["list"].unshift(path)
        if storage["list"].length == MAX_LENGTH + 1
          storage["list"].pop
        end
        storage.save
        Redcar.app.refresh_menu!
      end
      
      def self.remove_path(path)
        path = File.expand_path(path)
        storage["list"].delete(path)
        storage.save
        Redcar.app.refresh_menu!
      end
    end
  end
end