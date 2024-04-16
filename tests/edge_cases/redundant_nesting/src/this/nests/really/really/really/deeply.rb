module This
  def self.depth
    1
  end

  module Nests
    def self.depth
      2
    end

    module Really
      def self.depth
        3
      end

      module Really
        def self.depth
          4
        end

        module Really
          def self.depth
            5
          end

          class Deeply
            def self.depth
              6
            end
          end
        end
      end
    end
  end
end
