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

      %w{
        size duration bitrate sampleFrequency nrAudioChannels resolution
        protocolInfo
      }.each do |m|
        define_singleton_method(m) { extract_xpath("res/@#{m}") }
      end

      define_singleton_method('url') { extract_xpath("res") }
    end

    private
      def extract_xpath(xpath)
        @xml_node.xpath(xpath).text
      end
  end
end
