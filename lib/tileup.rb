require 'ostruct'
require 'RMagick'
require 'fileutils'

module TileUp

  class Tiler

    def initialize(image_filename, options)
      default_options = {
        auto_zoom_levels: nil,
        tile_width: 256,
        tile_height: 256,
        filename_prefix: "map_tile",
        output_dir: ".",
        verbose: false
      }
      @options = OpenStruct.new(default_options.merge(options))
      @options.tile_width = @options.tile_width.to_i unless !@options.tile_width.respond_to? :to_i
      @options.tile_height = @options.tile_height.to_i unless !@options.tile_height.respond_to? :to_i
      @extension = image_filename.split(".").last
      @filename_prefix = @options.filename_prefix

      begin
        @image = Magick::Image::read(image_filename).first
      rescue Magick::ImageMagickError => e
        puts "Could not open image #{image_filename}."
        exit
      end

      if @options.auto_zoom_levels && @options.auto_zoom_levels > 20
        puts "Warning: auto zoom levels hard limited to 20."
        @options.auto_zoom_levels = 20
      end
      if @options.auto_zoom_levels && @options.auto_zoom_levels <= 0
        @options.auto_zoom_levels = nil
      end

      puts "Opened #{image_filename}, #{@image.columns} x #{@image.rows}"

      # pre-process our inputs to work out what we're supposed to do
      tasks = []

      if @options.auto_zoom_levels.nil?
        # if we have no auto zoom request, then
        # we dont shrink or scale, and save directly to the output
        # dir.
        tasks << {
          output_dir: @options.output_dir, # normal output dir
          scale: 1.0 # dont scale
        }
      else
        # do have zoom levels, so construct those tasks
        zoom_name = 20
        scale = 1.0
        tasks << {
          output_dir: File.join(@options.output_dir, zoom_name.to_s),
          scale: scale
        }
        (@options.auto_zoom_levels-1).times do |level|
          scale = scale / 2.0
          zoom_name = zoom_name - 1
          tasks << {
            output_dir: File.join(@options.output_dir, zoom_name.to_s),
            scale: scale
          }
        end
      end

      # run through tasks list
      tasks.each do |task|
        image = @image
        image_path = File.join(task[:output_dir], @filename_prefix)
        if task[:scale] != 1.0
          # if scale required, scale image
          begin
            image = @image.scale(task[:scale])
          rescue RuntimeError => e
            message = "Failed to scale image, are you sure the original image "\
                      "is large enough to scale down this far (#{scale}) with this "\
                      "tilesize (#{@options.tile_width}x#{@options.tile_height})?"
            puts message
            exit
          end
        end
        # make output dir
        make_path(task[:output_dir])
        self.make_tiles(image, image_path, @options.tile_width, @options.tile_height)
        image = nil
      end

      puts "Finished."

    end

    def make_path(directory_path)
      FileUtils.mkdir_p directory_path
    end

    def make_tiles(image, filename_prefix, tile_width, tile_height)
      # find image width and height
      # then find out how many tiles we'll get out of
      # the image, then use that for the xy offset in crop.
      num_columns = (image.columns/tile_width.to_f).ceil
      num_rows = (image.rows/tile_height.to_f).ceil
      x,y,column,row = 0,0,0,0
      crops = []

      puts "Tiling image into columns: #{num_columns}, rows: #{num_rows}"

      while true
        x = column * tile_width
        y = row * tile_height
        crops << {
          x: x,
          y: y,
          row: row,
          column: column
        }
        column = column + 1
        if column >= num_columns
          column = 0
          row = row + 1
        end
        if row >= num_rows
          break
        end
      end

      crops.each do |c|
        ci = image.crop(c[:x], c[:y], tile_width, tile_height, true);
        print "Saving tile: #{c[:row]}, #{c[:column]}..." if @options.verbose
        ci.write("#{filename_prefix}_#{c[:column]}_#{c[:row]}.#{@extension}")
        print "\rSaving tile: #{c[:row]}, #{c[:column]}... saved\n" if @options.verbose
        ci = nil
      end
    end

  end

end
