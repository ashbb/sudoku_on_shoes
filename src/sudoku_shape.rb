# sudoku_shape.rb
class Shoes::Shape
  def color
    style[:fill]
  end
  
  def color= color
    style :fill => color
  end
  
  def num
    style[:num]
  end
  
  def num= num
    style :num => num
  end
end

class Shoes::Tagline
  def color
    style[:stroke]
  end
  
  def color= color
    style :stroke => color
  end
end