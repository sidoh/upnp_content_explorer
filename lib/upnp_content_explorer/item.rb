module UpnpContentExplorer
  class Item
    def initialize(xml_node)
      @xml_node = xml_node
      @props = {}

      %w{id parentID restricted}.each do |m|
        define_singleton_method(m) { extract_xpath("@#{m}") }
      end

      %w{title class date}.each do |m|
        define_singleton_method(m) { extract_xpath("#{m}") }
      end
    end

    def item_class
      @data[:class]
    end

    # def method_missing(key)
    #   return @data[key] if @data.has_key?(key)
    #   super
    # end

    private
      def extract_xpath(xpath)
        @xml_node.xpath(xpath).text
      end
  end
end
