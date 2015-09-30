module UpnpContentExplorer
  class Item
    def initialize(data)
      @data = data
    end

    def item_class
      @data[:class]
    end

    def method_missing(key)
      return @data[key] if @data.has_key?(key)
      super
    end
  end
end
