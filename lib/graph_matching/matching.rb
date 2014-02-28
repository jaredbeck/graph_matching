require 'set'

module GraphMatching
  class Matching < Set

    def assert_valid
      flat = to_a.flatten
      if flat.length != flat.uniq.length
        $stderr.puts "Invalid matching: #{inspect}"
        raise "Invalid matching: A vertex appears more than once. "
      end
    end

  end
end
