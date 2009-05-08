# sudoku_on_shoes.rb
require 'sudoku_shape'
require 'sudoku_rules'
require 'sudoku_methods'
require 'sudoku_solver'

$SUDOKU = '9819.sud'

class SudokuOnShoes < Shoes
  include Sudoku
  url '/', :index
  url '/play', :index
  url '/solution', :solution
  url '/create', :create

  def index
    background tomato
    $data = IO.read('../puzzles/' + $SUDOKU).
      gsub(/[^1-9\.]/, '').gsub('.', ' ').split('')[0, 81]
    @cells = []
    
    display $data, white do |r|
      @cells << r
      set_mouse r
    end
  
    set_lines  
    set_sudoku_no
    set_stage_link 'solution'
    set_select_link
    set_stage_link 'create', 180
    
    set_keypress
  end
  
  def create
    background gold
    $data = Array.new 81, ' '
    @cells = []
    
    display $data, white do |r|
      @cells << r
      set_mouse r
    end
  
    set_lines
    set_stage_link 'play'
    set_save_link
    
    set_keypress
  end
  
  def solution
    background lightskyblue
    board = Board.new(true).parse($data.to_s)
    board.solve
    solved = board.inspect[7, 81].split ''
    
    display solved, khaki
    
    set_lines
    set_sudoku_no
    set_stage_link 'play'
  end
  
end
  
Shoes.app :width => 300, :height => 330, :title => 'Sudoku on Shoes v0.3'