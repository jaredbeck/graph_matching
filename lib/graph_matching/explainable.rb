module Explainable

  def log(msg)
    puts msg if ENV['EXPLAIN']
  end

end
