require 'spec_helper'
require 'nokogiri'

describe MockUpnpContentDirectory do
  context 'hardcoded map' do
    let(:service) {
      MockUpnpContentDirectory.new({'0' => 'abc'})
    }

    it 'should return the appropriate value' do
      expect(service.Browse({ObjectID: '0'})).to eq({Result: 'abc'})
    end
  end

  context 'builder' do
    it 'should build a simple content tree' do
      service = MockUpnpContentDirectory.build do |root|
        root.add_item('a')
        root.add_item('b')
      end

      result = service.Browse(ObjectID: '0')[:Result].gsub('xmlns=', 'xmlns:didl=')
      xml = Nokogiri::XML(result)

      expect(xml.xpath('/DIDL-Lite/item').count).to eq(2)
    end

    it 'should build a deep content tree' do
      service = MockUpnpContentDirectory.build do |root|
        root.add_item('a1')

        root.add_child('b') do |b|
          b.add_item('b1')
          b.add_item('b2')

          b.add_child('c') do |c|
            c.add_item('c1')
            c.add_item('c2')
            c.add_item('c3')
          end
        end
      end

      result = service.Browse(ObjectID: '0$0')[:Result].gsub('xmlns=', 'xmlns:didl=')
      xml = Nokogiri::XML(result)

      expect(xml.xpath('/DIDL-Lite/item').count).to eq(2)

      result = service.Browse(ObjectID: '0$0$0')[:Result].gsub('xmlns=', 'xmlns:didl=')
      xml = Nokogiri::XML(result)

      expect(xml.xpath('/DIDL-Lite/item').count).to eq(3)
    end
  end

  context 'BrowseFlag should be respected' do
    let(:service) {
      MockUpnpContentDirectory.build do |root|
        root.add_item('a1')

        root.add_child('b') do |b|
          b.add_item('b1')
          b.add_item('b2')

          b.add_child('c') do |c|
            c.add_item('c1')
            c.add_item('c2')
            c.add_item('c3')
          end
        end
      end
    }

    it 'should respect BrowseDirectChildren' do
      result = service.Browse(ObjectID: '0', BrowseFlag: 'BrowseDirectChildren')[:Result].gsub('xmlns=', 'xmlns:didl=')
      xml = Nokogiri::XML(result)
      xml.remove_namespaces!

      expect(xml.xpath('/DIDL-Lite/item').count).to eq(1)
      expect(xml.xpath('/DIDL-Lite/container').count).to eq(1)

      expect(xml.xpath('/DIDL-Lite/item/title').text).to eq('a1')
      expect(xml.xpath('/DIDL-Lite/container/title').text).to eq('b')
    end

    it 'should respect BrowseMetadata' do
      result = service.Browse(ObjectID: '0$0', BrowseFlag: 'BrowseMetadata')[:Result].gsub('xmlns=', 'xmlns:didl=')
      xml = Nokogiri::XML(result)
      xml.remove_namespaces!

      expect(xml.xpath('/DIDL-Lite/container').count).to eq(1)
      expect(xml.xpath('/DIDL-Lite/container/@id').text).to eq('0$0')
      expect(xml.xpath('/DIDL-Lite/container/@parentID').text).to eq('0')
      expect(xml.xpath('/DIDL-Lite/container/title').text).to eq('b')
    end
  end
end
