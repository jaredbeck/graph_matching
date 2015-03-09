module GraphMatching
  module Algorithm

    # Can be mixed into MWMGeneral to add runtime assertions
    # about the data structures used for delta2/delta3 calculations.
    #
    # > Check delta2/delta3 computation after every substage;
    # > only works on integer weights, slows down the algorithm to O(n^4).
    # > (Van Rantwijk, mwmatching.py, line 34)
    #
    module MWMGDeltaAssertions

      def calc_delta_with_assertions(*args)
        # > Verify data structures for delta2/delta3 computation.
        # > (Van Rantwijk, mwmatching.py, line 739)
        check_delta2
        check_delta3
        calc_delta_without_assertions(*args)
      end

      # > Check optimized delta2 against a trivial computation.
      # > (Van Rantwijk, mwmatching.py, line 580)
      def check_delta2
        (0 ... @nvertex).each do |v|
          if @label[@in_blossom[v]] == MWMGeneral::LBL_FREE
            bd = nil
            bk = nil
            @neighb_end[v].each do |p|
              k = p / 2 # Note: floor division
              w = @endpoint[p]
              if @label[@in_blossom[w]] == MWMGeneral::LBL_S
                d = slack(k)
                if bk.nil? || d < bd
                  bk = k
                  bd = d
                end
              end
            end
            option1 = bk.nil? && @best_edge[v].nil?
            option2 = !@best_edge[v].nil? && bd == slack(@best_edge[v])
            unless option1 || option2
              raise "Assertion failed: Free vertex #{v}"
            end
          end
        end
      end

      # > Check optimized delta3 against a trivial computation.
      # > (Van Rantwijk, mwmatching.py, line 598)
      def check_delta3
        bk = nil
        bd = nil
        tbk = nil
        tbd = nil
        (0 ... 2 * @nvertex).each do |b|
          if @blossom_parent[b].nil? && @label[b] == MWMGeneral::LBL_S
            blossom_leaves(b).each do |v|
              @neighb_end[v].each do |p|
                k = p / 2 # Note: floor division
                w = @endpoint[p]
                if @in_blossom[w] != b && @label[@in_blossom[w]] == MWMGeneral::LBL_S
                  d = slack(k)
                  if bk.nil? || d < bd
                    bk = k
                    bd = d
                  end
                end
              end
            end
            if !@best_edge[b].nil?
              i, j = @edges[@best_edge[b]].to_a
              unless @in_blossom[i] == b || @in_blossom[j] == b
                raise 'Assertion failed'
              end
              unless @in_blossom[i] != b || @in_blossom[j] != b
                raise 'Assertion failed'
              end
              unless @label[@in_blossom[i]] == MWMGeneral::LBL_S &&
                  @label[@in_blossom[j]] == MWMGeneral::LBL_S
                raise 'Assertion failed'
              end
              if tbk.nil? || slack(@best_edge[b]) < tbd
                tbk = @best_edge[b]
                tbd = slack(@best_edge[b])
              end
            end
          end
        end
        unless bd == tbd
          raise 'Assertion failed'
        end
      end

    end
  end
end
