# sudoku_methods.rb

module Sudoku
  N = 15

  def set_lines
    4.times do |i|
      line N, i * 90 + N, 270 + N, i * 90 + N, :stroke => maroon, :strokewidth => 2
      line i * 90 + N, N, i * 90 + N, 270 + N, :stroke => maroon, :strokewidth => 2
    end
  end
  
  def set_sudoku_no
    para '#' + $SUDOKU.sub('.sud', ''), :left => 5, :top => 300, 
      :stroke => white, :weight => 'bold'
  end
  
  def set_stage_link name, x = 60
    para link(name, :click => "/#{name}"), :left => x, :top => 300
  end
  
  def set_select_link
    para link('select'){
      fname = ask_open_file
      $SUDOKU = File.basename(fname) and visit('/')  if fname =~ /\.sud$/
    }, :left => 120, :top=> 300
  end
  
  def set_keypress
    keypress do |key|
      if @cc.color == khaki and (('1'..'9').to_a << ' ').include? key
        @cc.num.text = key
        check_sudoku_rules
      end
    end
  end
  
  def set_mouse r
    r.click{(r.color= khaki; @cc = r) unless r.color == gainsboro}
    
    r.leave do |r| 
      if r.color == khaki
        r.color= white
        @tmp.each{|tmp| tmp.num.color = tmp.color == gainsboro ? black : green}
        (@cc.num.text, @cc.num.color = ' ', green) unless @tmp.empty?
      end
    end
  end
  
  def display data, bcolor = white
    n = 0
    stack :margin => N do
      9.times do |j|
        9.times do |i|
          x, y = i * 30, j * 30
          r = rect(x, y, 30, 30, :fill => $data[n] == ' ' ? bcolor : gainsboro)
          (yield r) if block_given?
          r.num = tagline(data[n], :left => x + N + 5, :top => y + N, 
            :stroke => r.color == gainsboro ? black : green)
          n += 1
        end
      end
    end
  end
  
  def set_save_link
    para link('save'){
      fname = ask_save_file
      open(fname, 'w'){|f| f.puts save_data} if fname
    }, :left => 120, :top=> 300
  end
  
  def save_data
    ret = []
    @cells.each_with_index do |cell, i|
      ret << ((t = cell.num.text) == ' ' ? '.' : t)
      (ret << "\n")  if i % 9 == 8 
    end
    ret.to_s
  end
  
end
