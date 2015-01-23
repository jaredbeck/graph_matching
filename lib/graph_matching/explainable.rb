# encoding: utf-8

module Explainable

  def log(msg)
    puts msg if ENV['EXPLAIN']
  end

  # `timestamp` is only used in development, for very simple profiling.
  def timestamp(id)
    t = Time.now.to_f
    delta = $gm_ts.nil? ? 0 : t - $gm_ts
    puts '%20.4f %20.4f %s' % [t, delta, id]
    $gm_ts = t
  end

end
