require 'pathname'

require 'nokogiri'
require 'nori'

require 'upnp_content_explorer/node'
require 'upnp_content_explorer/item'

module UpnpContentExplorer
  class PathNotFoundError < StandardError; end

  class Explorer
    attr_accessor :root

    DEFAULT_OPTIONS = {
      root_id: 0
    }

    def initialize(service, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @service = service
      @root = load_root_node(@options[:root_id])
    end

    def get(path)
      find_terminal_node(prepare_path(path))
    end

    def root_path
      path = []
      current = @root

      while !current.nil? && current.id != Node::ROOT_ID
        path << current.title
        current = load_root_node(current.parent_id)
      end

      '/' << path.reverse.join('/')
    end

    def scrape(path)
      node = find_terminal_node(prepare_path(path))

      child_items = node.children.map do |child|
        scrape("#{path}/#{child.title}")
      end

      all_items = []
      all_items += node.items
      all_items += child_items.flatten
    end

    private
      def prepare_path(path)
        path = Pathname.new(path)
        path.each_filename.to_a
      end

      def find_terminal_node(path, node = @root, traversed_path = '')
        node.load!(get_node(node.id)) unless node.loaded?

        return node if path.empty?

        next_node = path.shift
        next_traversed_path = "#{traversed_path}/#{next_node}"
        child = node.child(next_node)

        raise PathNotFoundError, "Path doesn't exist: #{next_traversed_path}" if child.nil?

        find_terminal_node(path, child, next_traversed_path)
      end

      def load_root_node(id)
        Node.new(id: id, title: 'Root')
      end

      def get_node(node_id)
        response = @service.Browse(
            ObjectID: node_id,
            BrowseFlag: 'BrowseDirectChildren',
            Filter: '*',
            StartingIndex: '0',
            RequestedCount: '0'
        )

        node_data = response[:Result]
          .gsub('xmlns=', 'xmlns:didl=')
        content = Nokogiri::XML(node_data)
        content.remove_namespaces!

        children = content.xpath('/DIDL-Lite/container').map do |child|
          node_data = parse_nori_node(child)
          Node.new(node_data)
        end

        items = content.xpath('/DIDL-Lite/item').map do |item|
          Item.new(item)
        end

        children = Hash[ children.map { |x| [x.title, x] } ]
        items = Hash[ items.map { |x| [x.title, x] } ]

        { children: children, items: items }
      end

      def parse_nori_node(node)
        raw_map = Nori.new(:strip_namespaces => true).parse(node.to_xml)
        raw_map = raw_map[raw_map.keys.first]

        Hash[
            raw_map.map do |k,v|
              [k.gsub('@', '').to_sym, v]
            end
        ]
      end
  end
end
