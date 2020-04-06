require 'net/http'
require 'zlib'
require 'nokogiri'


class EasyBrokerSynchronizer
  class EasyBrokerDoc < Nokogiri::XML::SAX::Document
    def start_element name, attrs = []
      case name
      when 'property'
        @in_property = true
        @in_id = false

        @property_last_updated = attrs[0][1]
        
        @property_images = []
        @property_features = []
        #puts @property_last_updated
      when 'id'
        @in_id = true
      when 'agent'
        @in_agent = true
      when 'city_area'
        @in_city_area = true
      when 'image'
        @in_image = true
      when 'feature'
        @in_feature = true
      when 'title'
        @in_title = true
      when 'description'
        @in_description = true
      when 'operation'
        @in_operation = true
        @property_operation_type = attrs[0][1]
        #puts @property_operation_type
      when 'price'
        @in_price = true
        @property_price = attrs #currency, amount, currency
        @is_period = false
        @is_unit = false
        @is_amount = false
        @currency_code = ''

        attrs.each do |price|
          if price[0] == 'period'
            @is_period = true
          elsif price[0] == 'unit'
            @is_unit = true
          elsif price[0] == 'amount'
            @is_amount = true
            @amount = price[1]
          elsif price[0] == 'currency'
            @currency_code = price[1]
          end
        end

        if not @is_period and not @is_unit
          #saves price
          if @property_operation_type == 'sale'
            #puts 'Is Sale'
            @property_sale_price = @amount
          elsif @property_operation_type == 'rental'
            @property_rent = @amount
          end
          if @currency_code != ''
            @property_currency = Currency.find_by code: @currency_code
            if @property_currency == nil
              @property_currency = Currency.create(code: @currency_code)
            end
          end

        end
      end
    end

    def characters(string)
      if @in_id and @in_property and not @in_agent
        @property_external_id = string
        #puts "  property id: "+ string
      end
    end
  
    def cdata_block(string)
      if @in_city_area
        @property_neighborhood = string
        #puts "    neighborhood: " + string
      elsif @in_image
        @property_images.push(string)
        #puts "    image: " + string
      elsif @in_feature
        @property_features.push(string)
        #puts "    feature: " + string
      elsif @in_title
        @property_title = string
        #puts "    title: " + string
      elsif @in_description
        @property_description = string
        #puts "    description: " + string
      end
    end

    def end_element name, attrs = []
      case name
      when 'property'
        #puts @property_images
        #puts @property_features

        #search property in DB by its external_id
        @property = Property.find_by external_id: @property_external_id
        if @property == nil
          #adds a new property and publishes it
          @property = Property.new
          @property.external_id = @property_external_id
          @property.published = true
          @property.title = @property_title
          @property.description = @property_description
          if @property_operation_type == 'sale'
            @property.sale_price = @property_sale_price
          elsif @property_operation_type == 'rental'
            @property.rent = @property_rent
          end
          if @property_currency != nil
            @property.currency = @property_currency
          end
          #puts @currency_code
        elsif
          #check updated date on DB. If same date as in xml, do nothing. Else, update property.
          puts "updated at: "+@property.updated_at
        end
        
        @in_property = false
        @property_external_id = nil
        @property_images = []
        @property_features = []
        @property_title = nil
      when 'id'
        @in_id = false
      when 'agent'
        @in_agent = false
      when 'city_area'
        @in_city_area = false
      when 'image'
        @in_image = false
      when 'feature'
        @in_feature = false
      when 'title'
        @in_title = false
      when 'description'
        @in_description = false
      when 'operation'
        @in_operation = false
      when 'price'
        @in_price = false
      end
    end
  end

  def self.synchronize
    url = 'http://www.stagingeb.com/feeds/dc3122988c6d81d750eba0825adba94d049f0559/easybroker_MX.xml.gz'
    
    response = Net::HTTP.get_response(URI.parse(url))
    if response.code == "301"
      response = Net::HTTP.get_response(URI.parse(response.header['location']))
    end
    if response.code == "200"
      file = response.body
      xml_data = Zlib::GzipReader.new(StringIO.new(file))
      #easy_broker_xml = xml_data.read
      #noko = Nokogiri::XML(xml_data)
      parser = Nokogiri::XML::SAX::Parser.new(EasyBrokerDoc.new)
      parser.parse(xml_data)
    end
  end
end
