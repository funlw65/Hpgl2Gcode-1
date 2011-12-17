require 'optparse'

#module Hpgl2gcode

  class Options
    
    DEFAULT_THICKNESS = 0.0
    DEFAULT_Z_CLEAR = 3.0
    
    attr_reader :input_filename
    attr_reader :output_filename
    attr_reader :thickness
    attr_reader :z_clear
    
    def initialize(argv)
      @thickness = DEFAULT_THICKNESS
      @z_clear = DEFAULT_Z_CLEAR
      @input_filename = "";
      parse(argv)
    end
  
  private
  
    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: hpgl2gcode [ option]"
        
        opts.on("-t", "--thickness value", Float, "Board thickness") do |thickness|
          @thickness = thickness
        end
        
        opts.on("-c", "--z_clearance value", Float, "Z Height for pen to clear board") do |z_clear|
          @z_clear = z_clear
        end
        
        opts.on("-i", "--input path", String, "Path to input (hpgl)") do |fn|
          @input_filename = fn
        end
        
        opts.on("-o", "--output path", String, "Path to output (gcode)") do |fn|
          @output_filename = fn
        end
        
        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        
        begin
          argv = ["-h"] if argv.empty?
          opts.parse!(argv)
        rescue OptionParser::ParseError => e
              STDERR.puts e.message, "\n", opts
              exit(-1)
        end
        
      end
    end
  end
#end
