# sudoku_on_shoes.rb
require 'sudoku_shape'
require 'sudoku_rules'
require 'sudoku_methods'

class SudokuSolver
  eval IO.read('sudoku_solver.rb')
end

class SudokuGen
  eval IO.read('sudoku_generator.rb')
end

$SUDOKU = '9819.sud'

class SudokuOnShoes < Shoes
  include Sudoku
  url '/', :index
  url '/play', :index
  url '/solution', :solution
  url '/create(.)', :create
  url '/nosolution', :nosolution

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
    set_stage_link 'create0', 180
    
    set_keypress
  end
  
  def create flag
    background gold
    $data =  case flag
      when '0'
        Array.new(81, ' ')
      when '1'
        IO.read('../puzzles/' + $SUDOKU).
          gsub(/[^1-9\.]/, '').gsub('.', ' ').split('')[0, 81]
      when '2'
        SudokuGen::SudokuGenerator.new.generate.
          gsub(/[^1-9\.]/, '').gsub('.', ' ').split('')[0, 81]
      else
    end
    @cells = []
    
    display $data, white, white, green do |r|
      @cells << r
      set_mouse r
    end
    
    set_lines
    set_stage_link 'play'
    set_save_link
    set_load_link
    set_auto_link
    
    set_keypress
  end
  
  def solution
    background lightskyblue
    board = SudokuSolver::Board.new(true).parse($data.to_s)
    board.solve rescue visit '/nosolution'
    solved = board.inspect[7, 81].split ''
    
    display solved, khaki
    
    set_lines
    set_sudoku_no
    set_stage_link 'play'
    set_save_link solved, false
  end
  
  def nosolution
    para 'No Solution Found'
    set_stage_link 'play'
  end
  
end
  
Shoes.app :width => 300, :height => 330, :title => 'Sudoku on Shoes v0.5'