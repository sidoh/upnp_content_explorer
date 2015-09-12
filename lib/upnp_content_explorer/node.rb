module UpnpContentExplorer
  class Node
    def initialize(data)
      @data = data
    end

    def loaded?
      return false if @data[:loaded?].nil?
      @data[:loaded?]
    end

    def method_missing(key)
      return @data[key] if @data.has_key?(key)
      super
    end

    def load!(data)
      merged_data = @data.merge(data)
      merged_data[:loaded?] = true

      @data = merged_data
    end

    def children
      @data[:children].values || []
    end

    def items
      @data[:items].values || []
    end

    def child(key)
      @data[:children][key]
    end

    def item(key)
      @data[:items][key]
    end
  end
end
