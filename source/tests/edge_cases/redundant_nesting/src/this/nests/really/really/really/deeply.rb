module This
  def self.depth() = 1

  module Nests
    def self.depth() = 2

    module Really
      def self.depth() = 3

      module Really
        def self.depth() = 4

        module Really
          def self.depth() = 5

          class Deeply
            def self.depth() = 6
          end
        end
      end
    end
  end
end
