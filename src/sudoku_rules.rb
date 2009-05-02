# sudoku_rules.rb
module SudokuRules
  REGIONS = [[0,1,2,9,10,11,18,19,20],[3,4,5,12,13,14,21,22,23],[6,7,8,15,16,17,24,25,26],
            [27,28,29,36,37,38,45,46,47],[30,31,32,39,40,41,48,49,50],[33,34,35,42,43,44,51,52,53],
            [54,55,56,63,64,65,72,73,74],[57,58,59,66,67,68,75,76,77],[60,61,62,69,70,71,78,79,80]]
           
  def check_sudoku_rules
    @tmp = []
    @cc.num.color = green
    id = @cells.index @cc
    line = @cells[(id / 9) * 9, 9] - [@cc]
    i = -1
    colum = @cells.select{(id % 9) == ((i+=1) % 9)} - [@cc]
    region = []
    REGIONS.each{|cells| cells.each{|i| region << @cells[i] } if cells.include? id}
    region -= [@cc]
    
    [line, colum, region].each do |cells|
      cells.each do |r|
        r.num.color = r.color == gainsboro ? black : green
        (r.num.color = @cc.num.color = red; @tmp << r) if @cc.num.text == r.num.text
      end
    end
  end
end