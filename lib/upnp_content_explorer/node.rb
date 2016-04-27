module UpnpContentExplorer
  class Node
    ROOT_ID = '0'

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

    def load!(data, mark_loaded = true)
      merged_data = @data.merge(data)
      merged_data[:loaded?] ||= mark_loaded

      @data = merged_data
    end

    def parent_id
      @data[:parentID] || nil
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
