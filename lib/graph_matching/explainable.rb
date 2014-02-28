module Explainable

  def debug(msg)
    puts msg if ENV['EXPLAIN']
  end

end
