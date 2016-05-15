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

      @metadata = {}
      %w{
        size duration bitrate sampleFrequency nrAudioChannels resolution
        protocolInfo
      }.each do |m|
        v = extract_xpath("res/@#{m}")
        @metadata[m.to_sym] = v
        define_singleton_method(m) { v }
      end

      @metadata[:url] = extract_xpath('res')
      @metadata[:itemClass] = extract_xpath('class')

      %w{url itemClass}.each do |m|
        define_singleton_method(m) { @metadata[m.to_sym] }
      end
    end

    def metadata
      {}.merge(@metadata)
    end

    private
      def extract_xpath(xpath)
        @xml_node.xpath(xpath).text
      end
  end
end
