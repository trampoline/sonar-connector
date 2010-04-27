require 'fileutils'
require 'uuidtools'

module Sonar
  module Connector
    class FileStore
      MAX_FILENAME_LENGTH = 220
      UUID_SLICE_LENGTH = 3  # number of digits to break 
      UUID_RADIX = 20        # 3 digits in base 20 gives a reasonable max count of 8000 files or dirs in any one dir.
      UUID_PAD_LENGTH = 30   # must be a multiple of UUID_SLICE_LENGTH
      DIR_DEPTH = 2          # directory tree depth
      
      attr_reader :base_dir
      attr_reader :extension
      
      def initialize(base_dir, extension = ".txt")
        # ensure base_dir ends with a separator
        @base_dir = File.join base_dir, ''
        
        @extension = extension
        
        raise ArgumentError.new("extension cannot be .base") if extension == '.base'
        @base_file = File.join base_dir, "filestore.base"
        setup
      end
      
      def files
        return @files unless dirty?
        glob = File.join base_dir, "**", "*#{extension}"
        clean!
        @files = Dir[glob]
      end
      
      def add(content, suffix = nil)
        filename = new_filename suffix
        dirname = File.dirname(filename)
        FileUtils.mkdir_p dirname unless File.directory?(dirname)
        File.open(filename, "w") {|f| f << content}
        dirty!
        filename
      end
      
      def new_filename(suffix = nil)
        uuid = UUIDTools::UUID.timestamp_create.to_i.to_s(UUID_RADIX).rjust(UUID_PAD_LENGTH, "0")
        dirname = File.join base_dir, *uuid.scan(/.{1,#{UUID_SLICE_LENGTH}}/)[0..DIR_DEPTH]
        File.join dirname, [uuid, Time.now.to_i, suffix].compact.join("_") + extension
      end
      
      def count
        files.count
      end
      
      def inspect
        "#{@base_dir}: #{count} files"
      end
      
      alias :to_s :inspect
      
      private
      
      attr_reader :base_file
      
      def setup
        if File.directory?(base_dir)
          raise "#{base_dir} already exists and is not a file store." unless File.exist?(base_file)
          dirty!
        else
          FileUtils.mkdir_p base_dir
          FileUtils.touch base_file
          @files = []
          clean!
        end
      end
      
      def dirty?
        @dirty
      end
      
      def dirty!
        @dirty = true
      end
      
      def clean!
        @dirty = false
      end
      
    end
  end
end