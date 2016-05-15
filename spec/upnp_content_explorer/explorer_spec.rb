require 'spec_helper'

describe UpnpContentExplorer::Explorer do
  context 'fetching a node' do
    let(:service) {
      MockUpnpContentDirectory.build do |root|
        root.add_child('Movies') do |movies|
          movies.add_item('Inside Out (2015)')
        end
      end
    }

    let(:explorer) {
      UpnpContentExplorer::Explorer.new(service)
    }

    it 'should throw an exception if a node doesn\'t exist' do
      expect {
        explorer.get("/path/that/doesnot/exist")
      }.to raise_error(UpnpContentExplorer::PathNotFoundError)
    end

    it 'should successfully retrieve the root node' do
      node = explorer.get("/")
      expect(node).not_to be_nil
      expect(node.title).to eq('Root')
    end

    it 'should successfully retrieve the root children' do
      children = explorer.get("/").children
      expect(children).to be_an_instance_of Array
      expect(children.count).to eq(1)
      expect(children[0].title).to eq('Movies')
    end

    it 'should successfully retrieve the items of the root' do
      items = explorer.get("/").items
      expect(items).to be_an_instance_of Array
      expect(items.count).to eq(0)
    end

    it 'should retrieve a child node of the root successfully' do
      node = explorer.get("/Movies")
      expect(node).not_to be_nil
      expect(node.title).to eq('Movies')

      expect(node.children).to be_an_instance_of Array
      expect(node.children.count).to eq(0)

      expect(node.items).to be_an_instance_of Array
      expect(node.items.count).to eq(1)
      expect(node.items[0].title).to eq('Inside Out (2015)')
      expect(node.item('Inside Out (2015)').title).to eq('Inside Out (2015)')
    end

    it 'should retrieve a items of a child successfully' do
      items = explorer.get("/Movies").items
      expect(items).not_to be_nil

      expect(items.count).to eq(1)
      expect(items[0].title).to eq('Inside Out (2015)')
    end
  end

  context 'scraping' do
    let(:content_dir) {
      service = MockUpnpContentDirectory.build do |root|
        root.add_item('Inside Out (2015).mkv')

        root.add_child('Horror') do |horror|
          horror.add_child('1973') do |horror_1973|
            horror_1973.add_item('Exorcist (1973).mkv')
          end

          horror.add_child('2014') do |horror_2014|
            horror_2014.add_item('Annabelle (2014).avi')
            horror_2014.add_item('As Above, So Below (2014).avi')
          end
        end

        root.add_child('TV') do |tv|
          tv.add_child('Game of Thrones') do |got|
            got.add_child('Season 1') do |gots01|
              gots01.add_item('Game.of.Thrones.S01E01.mkv')
            end

            got.add_child('Season 2') do |gots02|
              gots02.add_item('Game.of.Thrones.S02E01.mkv')
            end
          end
        end
      end
    }

    let(:explorer) {
      UpnpContentExplorer::Explorer.new(content_dir)
    }

    it 'should be able to scrape an empty content directory' do
      service = MockUpnpContentDirectory.new(
          {
              '0' => <<-DIDL
                  <?xml version="1.0" encoding="UTF-8"?>
                  <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/">
                  </DIDL-Lite>
              DIDL
          }
      )
      explorer = UpnpContentExplorer::Explorer.new(service)
      result = explorer.scrape('/')

      expect(result).to be_an_instance_of Array
      expect(result.count).to eq(0)
    end

    it 'should scrape a more complicated content directory' do
      result = explorer.scrape('/')

      expect(result).to be_an_instance_of Array
      expect(result.map(&:title)).to contain_exactly(
                                         'Inside Out (2015).mkv',
                                         'Exorcist (1973).mkv',
                                         'Annabelle (2014).avi',
                                         'As Above, So Below (2014).avi',
                                         'Game.of.Thrones.S01E01.mkv',
                                         'Game.of.Thrones.S02E01.mkv'
                                     )
    end

    it 'should scrape a subdir' do
      result = explorer.scrape('/Horror')

      expect(result).to be_an_instance_of Array
      expect(result.map(&:title)).to contain_exactly(
                                         'Exorcist (1973).mkv',
                                         'Annabelle (2014).avi',
                                         'As Above, So Below (2014).avi'
                                     )
    end
  end
end
