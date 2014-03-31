class Chef
  class Recipe
    class VolumeHelper
      def self.builder(node)
        mounts = []
        unless node.deis.builder.packs.dir.nil?
          mounts << "#{node.deis.builder.packs.dir}:/buildpacks"
        end
        if node.deis.dev.mode == true
          mounts << "#{File.join(node.deis.dev.source, 'builder')}:/app"
        end
        mounts
      end

      def self.cache(node)
        mounts = []
        if node.deis.dev.mode == true
          mounts << "#{File.join(node.deis.dev.source, 'cache')}:/app"
        end
        mounts
      end

      def self.database(node)
        mounts = []
        if node.deis.dev.mode == true
          mounts << "#{File.join(node.deis.dev.source, 'database')}:/app"
        end
        mounts
      end

      def self.database_data(node)
        ['/var/lib/postgresql']
      end

      def self.logger(node)
        # share log directory between server and logger components
        # TODO: replace with a distributed mechanism for populating `deis logs`
        mounts = ["#{node.deis.log_dir}:/var/log/deis"]
        if node.deis.dev.mode == true
          mounts << "#{File.join(node.deis.dev.source, 'logger')}:/app"
        end
        mounts
      end

      def self.registry(node)
        mounts = []
        if node.deis.dev.mode == true
          mounts << "#{File.join(node.deis.dev.source, 'registry')}:/app"
        end
        mounts
      end

      def self.registry_data(node)
        ['/data']
      end

      def self.server(node)
        # share log directory between server and logger components
        # TODO: replace with a distributed mechanism for populating `deis logs`
        mounts = ["#{node.deis.log_dir}:/var/log/deis"]
        if node.deis.dev.mode == true
          mounts << "#{File.join(node.deis.dev.source, 'controller')}:/app"
        end
        mounts
      end
    end
  end
end
