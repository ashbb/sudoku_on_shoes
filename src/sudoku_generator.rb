#!/usr/bin/env ruby

# Created by Michael Uplawski
# Based on the sudoku_solver by Jim Weirich
# http://github.com/jimweirich/sudoku/tree/master

require 'logger'
require 'set'

# $LOG = Logger.new('/tmp/sudoku_generator.log') 
$LOG.level = Logger::DEBUG if $LOG


# for Ruby 1.8.6-compatibility
if(! Array.method_defined?(:count) )
	class ::Array
		def count()
			map{|element| yield(element) || nil }.compact.length
		end
	end
end
# A cell respresents a single location on the sudoku board.  Initially
# it holds no number, but a number can be manually assigned to the
# cell (which is then remembered for later).
#
# Each cell also belongs to 3 groups of cells, (1) the cells in its
# vertical column, (2) horizontal row, and (3) the 3x3 block of
# neighboring cells.  By looking at the cells in each of the groups,
# an individual cell can report on the list of possible numbers that
# are available for assignment to the cell. (If a cell already has an
# assigned number, the set of available numbers is empty).
#
class Cell
	attr_reader :number
	attr_reader :name

	OneThruNine = Set[*1..9]

	# Initialize a cell with the name :name.
	def initialize(name="unamed")
		@name = name
		@groups = []
	end

	# Assign a number to the cell.  Assigning nil or 0 leaves the cell
	# unassigned.
	def number=(value)
		@number = value.nonzero?
	end

	# Assign a random number to the cell
	def set_random(exclude) 
		$LOG.debug("available numbers for #{@name}: #{available_numbers.to_a.join(', ')}") if $LOG

		begin 
			@number = nil if @number
			an = available_numbers - exclude
			if(an and !an.empty?)
				srand
				@number = an.to_a[rand(an.size)]    
			else
				return nil
			end
		end until @number
		$LOG.debug("\t\tpicked: #{@number}") if $LOG

		return @number
	end
	# Return a set of numbers that could be assigned to the cell without
	# conflicting with any cells in any of the cell's groups.
	def available_numbers
		if number
			Set[]
		else
			@groups.inject(OneThruNine) { |res, group|
				res - group.numbers
			}
		end
	end

	# The cell joins the given group.
	def join(group)
		@groups << group
	end

	# Provide a string representation of the cell.
	def to_s
		@name
	end

	# Provided an inspect string for the cell.
	def inspect
		to_s
	end
end


# Cells are organized into groups.  Each group consists of 9 cells
# where the number assigned to a cell must be unique within the group.
# Groups are able to report the current set of assigned numbers within
# the group.
class Group

	# Initialize a group.
	def initialize
		@cells = []
	end

	# Add a cell to the given group.  Make sure the cell knows that it
	# has joined the group.
	def <<(cell)
		cell.join(self)
		@cells << cell
		self
	end

	# Return a set of numbers assigned to the cells in this group.
	def numbers
		Set[*@cells.map { |c| c.number }.compact]
	end
end

# A Sudoku board contains the 81 cells required by the puzzle.  The
# groupings of the cells is specified by the board in the
# :define_groups method.  The standard grouping is 9 row groups, 9
# column groups and 9 3x3 groups.
#
class Board
	include Enumerable

	# Initialize a board with a set of unassigned cells.
	def initialize(verbose=nil)
		@verbose = verbose
	end

	def create_empty
		@cells = (0...81).map { |i|
			Cell.new("C#{(i/9)+1}#{(i%9)+1}")
		}
		define_groups
	end

	# create a randomly but completely filled
	# game board
	def fill()
		passes = 0
		tested = Array.new
		begin
			n = 0
			create_empty
			passes += 1
			$LOG.debug("pass #{passes}") if $LOG

			$LOG.debug '==================' if $LOG

			each do |cell|
				if(n)
					i = 0
					tested.clear
					begin 
						cell.number = 0
						i += 1
						n = cell.set_random(tested)
						tested << n if n
						$LOG.debug("\t\tcell #{cell.name}, trying #{cell.number || 'nothing'}. Stuck? #{stuck?}, attempt #{i}") if $LOG

					end while stuck? && i < 9 && n 
				end
			end
			$LOG.debug("end of pass #{passes}, success? #{n != nil}") if $LOG

		end until n || passes >= 100
	end

	# clear a few cells from a completed Sudoku
	# but not so many, that the Sudoku has more than
	# one solution!
	def clear_nonambiguous()
		$LOG.debug("clearing some cells...") if $LOG

		times_solved = nil
		good_number = nil
		cell = nil
		available_cells = @cells.dup
		begin
			srand
			begin
				cell = available_cells[rand(available_cells.size)]
			end until cell.number
			available_cells.delete(cell)
			$LOG.debug("\tchose cell #{cell.name}, number #{cell.number}") if $LOG

			good_number = cell.number
			cell.number = 0
			an = cell.available_numbers
			$LOG.debug("\tCell #{cell.name}, available numbers now: #{an.to_a.join(', ')}") if $LOG

			times_solved = 0
			an.each do |test_n|
				cell.number = test_n 
				if(!stuck?)
					times_solved += 1
				end
			end
			if(times_solved > 1)
				cell.number = good_number
			else
				cell.number = 0
			end
		end until available_cells.empty?
		return @cells.count {|c| c.number}
	end

	# Iterate over the cells of the puzzle.  Iteration starts in the
	# upper left corner and continues across each row.
	def each
		@cells.each do |cell|
			yield cell
		end
	end

	# Has the puzzle been solved?  In other words, have all the cells
	# been assigned numbers?
	def solved?
		all? { |cell| cell.number }
	end

	# Are we stuck?  In other words, is there an unassigned cell where
	# there are no available numbers to be assigned to it.
	def stuck?
		any? { |cell| cell.number.nil? && cell.available_numbers.size == 0 }
	end

	# Provide a human readable version of the board in a grid format.
	def to_s
		encoding.
			gsub(/.../, "\\0 ").
			gsub(/.{12}/, "\\0\n").
			gsub(/.{39}/m, "\\0\n").
			gsub(/[\d.]/, "\\0 ")
	end

	# Provide a inspect string for a board.
	def inspect
		"<Board #{encoding}>"
	end

	# Encode the board into an 81 character string.  Each character
	# represents the number stored in each cell.  Unassigned cells are
	# represented by a '.'.  Cells are ordered starting in the upper
	# left corner and sweeping first left to right across the row, and
	# then each successive row.
	def encoding
		map { |cell| cell.number || "." }.join
	end

	# Solve the puzzle represente by the board.  The solution algorithm
	# is roughly:
	#
	# * Put numbers in all the cells where there is only one
	#   possible choice (the _easy_ squares).
	# * If all cells have been assigned, then we are done!
	# * If all unassigned cells have no possibilities, then we
	#   are stuck.  Backtrack by restoring the state of the board
	#   to the last guess and make a different guess.  If there
	#   are no more alternatives, then we have failed to solve
	#   the puzzle.
	# * Otherwise, just pick one of the cells with the fewest
	#   possible numbers (to minimize backtracking) and just guess
	#   at one of the numbers.  Remember the other choices in
	#   case we need to backtrack.
	#
	def solve
		alternatives = []
		while true
			solve_easy_cells
			break if solved?
			if stuck?
				fail "No Solution Found" if alternatives.empty?
				#puts "Backtracking (#{alternatives.size})" if @verbose
				guess(alternatives)
			else
				cell = find_candidate_for_guessing
				remember_alternatives(cell, alternatives)
				guess(alternatives)
			end
		end
	end

	private

	# Work toward a solution by assigning numbers to all the cells that
	# have only one possibility.
	def solve_easy_cells
		while solve_one_easy_cell
		end
	end

	# Find a cell with only one possibility and fill it.  Return true if
	# you are able to fill a square, otherwise return false.
	def solve_one_easy_cell
		each do |cell|
			an = cell.available_numbers
			if an.size == 1
				#puts "Put #{an.to_a.first} at (#{cell})" if @verbose
				cell.number = an.to_a.first
				return true
			end
		end
		return false
	end

	# Find a candidate cell for guessing.  The candidate must be an
	# unassigned cell.  Prefer cells with the fewest number of available
	# numbers (just to minimize backtracking).
	def find_candidate_for_guessing
		unassigned_cells.sort_by { |cell| 
			[cell.available_numbers.size, to_s]
		}.first
	end

	# Return a list of unassigned cells on the board.
	def unassigned_cells
		to_a.reject { |cell| cell.number }
	end

	# Remember the all the alternative choices for the given cell on the
	# list of alternatives.  An alternative is stored as a 3-tuple
	# consisting of the current encoded state of the board, the cell and
	# an available number.
	def remember_alternatives(cell, alternatives)
		cell.available_numbers.each do |n|
			alternatives.push([encoding, cell, n])
		end
	end

	# Make a guess by pulling an alternative from the list of remembered
	# alternatives and.  The state of the board at the remembered
	# alternative is restored and the choice is made for that cell.
	def guess(alternatives)
		state, cell, number = alternatives.pop
		parse(state)
		#puts "Guessing #{number} at #{cell}" if @verbose
		cell.number = number        
	end

	# Define the groups of cells for this puzzle.  Override this method
	# if you wish to create board that support non-standard cell
	# groupings (such as http://www.websudoku.com/variation/?day=2)
	def define_groups
		define_columns
		define_rows
		define_blocks
	end

	# Define row groups.
	def define_rows
		define_groupings(
			"aaaaaaaaa" +
			"bbbbbbbbb" +
			"ccccccccc" +
			"ddddddddd" +
			"eeeeeeeee" +
			"fffffffff" +
			"ggggggggg" +
			"hhhhhhhhh" +
			"iiiiiiiii")
	end

	# Define column groups.
	def define_columns
		define_groupings(
			"abcdefghi" +
			"abcdefghi" +
			"abcdefghi" +
			"abcdefghi" +
			"abcdefghi" +
			"abcdefghi" +
			"abcdefghi" +
			"abcdefghi" +
			"abcdefghi")
	end

	# Define block groups.
	def define_blocks
		define_groupings(
			"aaabbbccc" +
			"aaabbbccc" +
			"aaabbbccc" +
			"dddeeefff" +
			"dddeeefff" +
			"dddeeefff" +
			"ggghhhiii" +
			"ggghhhiii" +
			"ggghhhiii")
	end

	# Define a set of groups as specified by a 9x9 string stored in
	# row-major format.  Each position in the string represents a cell
	# on the grid.  Each character value in the string represents a
	# grouping of cells.  All cell positions with the same character
	# will be put in the same group.
	def define_groupings(string)
		groups = Hash.new { |h, k| h[k] = Group.new }
		group_ids = string.split(//)
		each do |cell|
			group_id = group_ids.shift
			next unless group_id =~ /^[a-zA-Z]$/
				groups[group_id] << cell
		end
	end
end


class SudokuGenerator
	@@difficulty = {:easy => 41, :medium => 36, :hard => 33}

	def initialize(level = :easy)
		@level = level.to_sym
	end

	def new_board()
		Board.new(true)
	end

	def generate()
		begin
			board = new_board()
			board.fill
			$LOG.debug('--------- sudoku completed ------------') if $LOG

			$LOG.debug("\n#{board.to_s}") if $LOG

			num = board.clear_nonambiguous 
			$LOG.debug('--------- new sudoku puzzle ------------') if $LOG
			$LOG.debug("\n#{board.to_s}\n#{num} given numbers.") if $LOG
		end until num < @@difficulty[@level]
		return board.to_s
	end

	def run(args)
		if args.empty?
			puts "Usage: ruby sudoku_generator.rb sud-file..."
			exit 
		end

		args.each do |fn|
			puts "Generating #{fn} ----------------------------------------------"
			puts
			open(fn, 'w+') do |f|
				f.write(generate())
			end
		end
	end
end

if __FILE__ == $0 then
	SudokuGenerator.new('medium').run(ARGV)
end
