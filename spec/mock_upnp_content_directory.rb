class MockUpnpContentDirectory
  def initialize(responses_by_id)
    @responses_by_id = responses_by_id
  end

  def Browse(params)
    browse_flag = params[:BrowseFlag] || 'BrowseDirectChildren'
    id = params[:ObjectID].to_s

    if browse_flag == 'BrowseDirectChildren'
      { Result: @responses_by_id[id] }
    elsif browse_flag == 'BrowseMetadata'
      if id == '0'
        {
          Result: <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
              <container id="0" parentID="-1">
                <dc:title>root</dc:title>
              </container>
            </DIDL-Lite>
          XML
        }
      else
        node = @responses_by_id
          .values
          .map { |x| Nokogiri::XML(x).xpath("//*[@id = '#{id}']") }
          .reject(&:empty?)
          .first

        {
          Result: <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
            #{node.to_xml}
          </DIDL-Lite>
          XML
        }
      end
    else
      raise "Invalid BrowseFlag: #{browse_flag}"
    end
  end

  def self.build(&block)
    builder = Builder.new('root')
    block.call(builder)
    MockUpnpContentDirectory.new(builder.build)
  end

  class Builder
    attr_reader :title

    def initialize(title)
      @title = title
      @children = []
      @items = []
    end

    def add_child(title, &block)
      child = Builder.new(title)
      block.call(child) if block
      @children << child
    end

    def add_item(title, children_xml = "")
      @items << { title: title, children_xml: children_xml }
    end

    def build(id = '0')
      children_nodes = {}

      children_xml = @children.each_with_index.map do |child, i|
        child_id = "#{id}$#{i}"
        children_nodes = children_nodes.merge(child.build(child_id))
        "<container id=\"#{child_id}\" parentID=\"#{id}\"><dc:title>#{child.title}</dc:title></container>"
      end

      items_xml = @items.each_with_index.map do |item, i|
        item_id = "#{id}$i#{i}"
        <<-XML
        <item id="#{item_id}" parentID="#{id}">
          <dc:title>#{item[:title]}</dc:title>
          <upnp:class>object.item.videoItem</upnp:class>
          #{item[:children_xml]}
        </item>
        XML
      end

      response = <<-DIDL
                     <?xml version="1.0" encoding="UTF-8"?>
                     <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
                       #{children_xml.join("\n")}
                       #{items_xml.join("\n")}
                     </DIDL-Lite>
                 DIDL

      {id => response}.merge(children_nodes)
    end
  end
end
