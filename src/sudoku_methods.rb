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
    para '#' + File.basename($SUDOKU).sub('.sud', ''), :left => 5, :top => 300, 
      :stroke => white, :weight => 'bold'
  end
  
  def set_stage_link name, x = 60
    para link(name.sub(/\d/, ''), :click => "/#{name}"), :left => x, :top => 300
  end
  
  def set_select_link
    para link('select'){
      fname = ask_open_file
      $SUDOKU = fname and visit('/')  if fname =~ /\.sud$/
    }, :left => 120, :top=> 300
  end
  
  def set_load_link
    para link('load'){
      fname = ask_open_file
      $SUDOKU = fname and visit('/create1')  if fname =~ /\.sud$/
    }, :left => 180, :top=> 300
  end
  
  def set_auto_link
    para link('auto'){visit '/create2'}, :left => 240, :top=> 300
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
  
  def display data, bcolor1 = white, bcolor2 = gainsboro, scolor = black
    n = 0
    stack :margin => N do
      9.times do |j|
        9.times do |i|
          x, y = i * 30, j * 30
          r = rect(x, y, 30, 30, :fill => $data[n] == ' ' ? bcolor1 : bcolor2)
          (yield r) if block_given?
          r.num = tagline(data[n], :left => x + N + 5, :top => y + N, 
            :stroke => r.color == bcolor2 ? scolor : green)
          n += 1
        end
      end
    end
  end
  
  def set_save_link solved = false, flag = true
    para link('save'){
      fname = ask_save_file
      if fname =~ /\.sud$/
        $SUDOKU = fname if flag
        open(fname, 'w'){|f| f.puts save_data(solved)}
      end
    }, :left => 120, :top=> 300
  end
  
  def save_data solved
    ret = []
    cells = solved ? solved : @cells
    cells.each_with_index do |cell, i|
      ret << ((t = solved ? cell : cell.num.text) == ' ' ? '.' : t)
      (ret << "\n")  if i % 9 == 8 
    end
    ret.to_s
  end
  
end
