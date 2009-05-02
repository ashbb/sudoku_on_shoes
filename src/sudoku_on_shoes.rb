# sudoku_on_shoes.rb
require 'sudoku_shape'
require 'sudoku_rules'
require 'sudoku_solver'

N = 15

class SudokuOnShoes < Shoes
  include SudokuRules
  url '/', :index
  url '/play', :index
  url '/solution', :solution

  def index
    background tomato
    $data = IO.read('../puzzles/9819.sud').
      gsub(/[^1-9\.]/, '').gsub('.', ' ').split('')[0, 81]
    
    @cells, @tmp, @cc, n = [], [], nil, 0
    
    stack :margin => N do
      9.times do |j|
        9.times do |i|
          x, y = i * 30, j * 30
          r = rect(x, y, 30, 30, :fill => $data[n] == ' ' ? white : gainsboro)
          @cells << r
          r.click{(r.color= khaki; @cc = r) unless r.color == gainsboro}
          r.leave do |r| 
            if r.color == khaki
              r.color= white
              @tmp.each{|tmp| tmp.num.color = tmp.color == gainsboro ? black : green}
              (@cc.num.text, @cc.num.color = ' ', green) unless @tmp.empty?
            end
          end
          r.num = tagline($data[n], :left => x + N + 5, :top => y + N, 
            :stroke => r.color == gainsboro ? black : green)
          n += 1
        end
      end
    end
  
    set_lines_and_links
    
    keypress do |key|
      if @cc.color == khaki and (('1'..'9').to_a << ' ').include? key
        @cc.num.text = key
        check_sudoku_rules
      end
    end
  end
  
  def solution
    background lightskyblue
    board = Board.new(true).parse($data.to_s)
    board.solve
    solved = board.inspect[7, 81].split ''
    
    n = 0
    stack :margin => N do
      9.times do |j|
        9.times do |i|
          x, y = i * 30, j * 30
          r = rect(x, y, 30, 30, :fill => $data[n] == ' ' ? khaki : gainsboro)
          tagline(solved[n], :left => x + N + 5, :top => y + N, 
            :stroke => r.color == gainsboro ? black : green)
          n += 1
        end
      end
    end
    
    set_lines_and_links 'play'
  end
  
  def set_lines_and_links name = 'solution'
    4.times do |i|
      line N, i * 90 + N, 270 + N, i * 90 + N, :stroke => maroon, :strokewidth => 2
      line i * 90 + N, N, i * 90 + N, 270 + N, :stroke => maroon, :strokewidth => 2
    end
    para link(name, :click => "/#{name}"), :left => 15, :top => 300
  end
end
  
Shoes.app :width => 300, :height => 330, :title => 'Sudoku on Shoes v0.2'