class String
  
  def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end
end

class Hpgl2gcode
  def hp2mm(value)
    if (value.class == String)
      value = value.to_f
    end
  
    value/40.0
  end

    def limit_acc(n)
      r = (n * 1000.0) + 1.0
      r = r.round
      r = r / 1000.0
      r
    end
    
    def plot_polycircle(x_centre, y_centre, arc_degrees)
      result = ""
      rad = (((x_centre - @current_x) * (x_centre - @current_x)) + ((y_centre - @current_y) * (y_centre - @current_y))) ** 0.5
      
      rad = limit_acc(rad)
    
      result += "G1 X#{x_centre} Y#{y_centre}\n"
      
      pi = 3.141
      
      0.step(2.0 * pi, 2.0 * pi / 15.0) {|i|
        result += "G1 X#{limit_acc(x_centre + rad * Math.cos(i))} Y#{limit_acc(y_centre+rad*Math.sin(i))}\n"
      }
      result
    end
    
    def process(line_num, l)
      if l.starts_with?('PU') 
        return("G1 Z3\n")
      elsif l.starts_with?('PD') 
        return("G1 Z0\n")
      elsif l.starts_with?('PA') 
        pos = l.match(/(\w+),(\w+);/)
        # p pos
        @current_x = hp2mm(pos[1])
        @current_y = hp2mm(pos[2])
        return ("G1 X#{@current_x} Y#{@current_y}\n")
      elsif l.starts_with? 'IN'
        return "G21\nG90\n"
      elsif l.starts_with? 'IP'
      elsif l.starts_with? 'SP'
      elsif l.starts_with? 'SC'
      elsif l.starts_with? 'AA'
        pos = l.match(/(\w+),(\w+),(\w+);/)
        return plot_polycircle(hp2mm(pos[1]), hp2mm(pos[2]), pos[3].to_i)
      elsif l.empty?
      else 
        $stderr.print("Line #{line_num}: '#{l}' : is not handled\n")
      end
      return ""
    end
    
    
    def process_cmdline
    end
    
    # 
    # def process_command(cmd)
    #   args = Array(cmd)
    #   command = args.shift
    #   case(command)
    #   when "+" 
    #     add_task(args[0])     
    #   when "@" 
    #     t = tasks 
    #     puts t.empty? ? "Looks like you have nothing to do.\n" : t
    # 
    #   # ... other commands omitted
    # 
    #   else
    #     puts "Que?" 
    #   end
    # end

    def execute
      process_cmdline()
    
    
      lines = IO.readlines("./test.hpgl", ";")
      lines.each_with_index{|l, i| 
        r = process(i, l.strip)
        print r unless r.nil? || r.empty?
      }
    end
end

# app = Hpgl2gcode.new
# app.execute()
 