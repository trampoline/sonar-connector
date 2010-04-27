require 'fileutils'
require 'uuidtools'

module Sonar
  module Connector
    class FileStore
      # MAX_FILENAME_LENGTH = 220 # not used yet.
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
      
      # return a list of all files in the filestore
      def files
        return @files unless dirty?
        glob = File.join base_dir, "**", "*#{extension}"
        clean!
        @files = Dir.glob(glob)
      end
      
      # create a new file in this filestore
      def add(content, suffix = nil)
        filename = new_filename suffix
        ensure_dir_exists File.dirname(filename)
        File.open(filename, "w") {|f| f << content}
        dirty!
        filename
      end
      
      # move the file from this filestore to the specified filestore. Filename can be a path or a basename
      # to a file in this filestore. The path will be ignored anyway.
      def move(filename, filestore, skip_contains_check = false)
        raise "file '#{filename}' doesn't exist in this filestore." if !skip_contains_check && !self.contains?(filename)
        basename = File.basename(filename)
        source_file = File.join path_from_basename(basename), basename
        target_file = File.join filestore.send(:path_from_basename, basename), basename
        filestore.send :ensure_dir_exists, File.dirname(target_file)
        FileUtils.mv source_file, target_file
        dirty!
        filestore.send :dirty!
      end
      
      # move all the files in the current filestore to another filestore
      def move_all_to(filestore)
        files.each do |filename|
          move filename, filestore, true
        end
        dirty!
        filestore.send :dirty!
      end
      
      # Returns true if the given filename exists in the filestore, false if it does not. Ignores path of filename.
      def contains?(filename)
        basename = File.basename(filename)
        File.exist? File.join(path_from_basename(basename), basename)
      end
      
      # Count of files in the filestore.
      def count
        files.count
      end
      
      # String representation of a filestore.
      def inspect
        "#{@base_dir}: #{count} files"
      end
      alias :to_s :inspect
      
      private
      
      attr_reader :base_file
      
      # Create the filestore if it doesn't exist already.
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
      
      # Generate the full path and name of a new file.
      def new_filename(suffix = nil)
        uuid = UUIDTools::UUID.timestamp_create.to_i.to_s(UUID_RADIX).rjust(UUID_PAD_LENGTH, "0")
        basename = [uuid, Time.now.to_i, suffix].compact.join("_") + extension
        filename = File.join path_from_basename(basename), basename
      end
      
      # Make the dir unless it already exists.
      def ensure_dir_exists(dir)
        FileUtils.mkdir_p dir unless File.directory?(dir)
      end
      
      # return the would-be path to a file given a file's basename.
      def path_from_basename(basename)
        File.join base_dir, *basename.scan(/.{1,#{UUID_SLICE_LENGTH}}/)[0..DIR_DEPTH]
      end
      
      # Returns true if the filestore cache is dirty.
      def dirty?
        @dirty
      end
      
      # Sets the dirty flag on the filestore cache.
      def dirty!
        @dirty = true
      end
      
      # Marks the filestore cache as clean.
      def clean!
        @dirty = false
      end
      
    end
  end
end