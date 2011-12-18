require './lib/hpgl2gcode/gcode.rb'
require './lib/hpgl2gcode/options'

describe "hpgl2gcode" do

  before(:each) do
    @uut = Hpgl2gcode.new
  end
  
  context "Generating GCode" do
    
    it "should output a g1 up command when PU received" do
      @uut.process_cmdline(["-t", "4", "-i", "test.gcode"])
      @uut.process(1, "PU;").should eql("G1 Z3.0 F5.0\n")
    end
  
    it "should output a g21 g90 when IN received" do
      @uut.process(1, "IN;").should eql("G21\nG90\n")
    end
  
    it "should output a g1 down command when PD received" do
      @uut.process_cmdline(["-c", "4", "-i", "test.gcode"])
      @uut.process(1, "PD;").should eql("G1 Z0.0 F5.0\n")
    end
  
    it "should output a g1 draw with draw feedrate when pen is down" do
      @uut.process_cmdline(["-f", "10.3", "-i", "test.gcode"])
      @uut.pendown=true
      @uut.process(1, "PA 959,1855;").should eql("G1 X23.975 Y46.375 F10.3\n")
    end
    
    it "should output a g1 draw with travel feedrate when pen is up" do
      @uut.process_cmdline(["-t", "60", "-i", "test.gcode"])
      @uut.pendown=false
      @uut.process(1, "PA 959,1855;").should eql("G1 X23.975 Y46.375 F60.0\n")
    end
    
    it "should output a g1 draw with 1mm X 2mm Y when PA received" do
      @uut.process_cmdline(["-f", "10.7", "-i", "test.gcode"])
      @uut.pendown = true
      @uut.process(1, "PA 40,80;").should eql("G1 X1.0 Y2.0 F10.7\n")
    end
  
    it "should set the correct Z value when a thickness parameter has been set" do
      @uut.process_cmdline(['-t', '2.5', "-i", "test.gcode"])
      @uut.process(1, "PD;").should eql("G1 Z2.5 F5.0\n")
    end
  
    it "should set the correct Z value when a z_clear parameter has been set" do
      @uut.process_cmdline(['-c', '6.5', "-i", "test.gcode"])
      @uut.process(1, "PU;").should eql("G1 Z6.5 F5.0\n")
    end

    it "should read the correct input file and write the correct output file" do
      opname = "spec/results/basic.gcode" 
      ARGV.clear.push *%w(-i spec/data/basic.hpgl -o)
      ARGV.push opname
      File.delete(opname) if File.exists?(opname)
      @uut.execute()
      File.exists?(opname).should eql(true)
      
      
      expected = IO.readlines("spec/expected/basic.gcode")
      actual = IO.readlines(opname)
      actual.should eql(expected)
    end

  end
  
  context "Parse commandline correctly" do
    it "should parse a -t correctly" do
      opts = Options.new(["-t", "0.5", "-i", "test.gcode"])
      opts.thickness.should eql(0.5)      
    end
    
    it "should parse a --thickness correctly" do
      opts = Options.new(["--thickness", "1.5", "-i", "test.gcode"])
      opts.thickness.should eql(1.5)      
    end
    
    it "should parse a -c correctly" do
      opts = Options.new(["-c", "2.5", "-i", "test.gcode"])
      opts.z_clear.should eql(2.5)      
    end
    
    it "should parse a --z_clearance correctly" do
      opts = Options.new(["--z_clearance", "3.5", "-i", "test.gcode"])
      opts.z_clear.should eql(3.5)      
    end

    it "should setup input filename" do
      opts = Options.new(["-i", "test.hpgl"])
      opts.input_filename.should eql("test.hpgl")      
    end

    it "should setup default output filename if -o is missing" do
      opts = Options.new(["-i", "test.hpgl"])
      opts.output_filename.should eql("test.gcode")      
    end

    it "should setup output filename" do
      opts = Options.new(["-o", "test2.gcode", "-i", "test.gcode"])
      opts.output_filename.should eql("test2.gcode")      
    end

    it "should parse a -f feedrate correctly" do
      opts = Options.new(["-f", "10", "-i", "test.gcode"])
      opts.feedrate.should eql(10.0)      
    end
    
    it "should parse a -r travelrate correctly" do
      opts = Options.new(["-r", "10", "-i", "test.gcode"])
      opts.travelrate.should eql(10.0)      
    end
    
    it "should parse a -z travelrate correctly" do
      opts = Options.new(["-z", "11", "-i", "test.gcode"])
      opts.zrate.should eql(11.0)      
    end
    
  end
end
