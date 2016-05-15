class MockUpnpContentDirectory
  def initialize(responses_by_id)
    @responses_by_id = responses_by_id
  end

  def Browse(params)
    { Result: @responses_by_id[params[:ObjectID].to_s] }
  end

  def self.build(&block)
    builder = Builder.new('Root')
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

    def add_item(title)
      @items << title
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
        "<item id=\"#{item_id}\"><dc:title>#{item}</dc:title></item>"
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
