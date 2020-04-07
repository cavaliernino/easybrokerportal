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
        @has_agent = false
        @property_last_updated = attrs[0][1]
        
        @property_images = []
        @property_features = []
      when 'id'
        @in_id = true
      when 'agent'
        @in_agent = true
        @has_agent = true
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
      when 'price'
        @in_price = true
        @property_price = attrs
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
      when 'bedrooms'
        @in_bedrooms = true
      when 'bathrooms'
        @in_bathrooms = true
      when 'parking_spaces'
        @in_parking_spaces = true
      when 'property_type'
        @in_property_type = true
      when 'name'
        @in_name = true
      when 'email'
        @in_email = true
      when 'cell'
        @in_cell = true
      end
    end





    def characters(string)
      if @in_id and @in_property and not @in_agent
        @property_external_id = string
      elsif @in_id and @in_property and @in_agent
        @property_agent_id = string
      elsif @in_bedrooms
        @property_bedrooms = string
      elsif @in_bathrooms
        @property_bathrooms = string
      elsif @in_parking_spaces
        @property_parking_spaces = string
      end
    end
  


    
    def cdata_block(string)
      if @in_city_area
        @property_neighborhood = string
      elsif @in_image
        @property_images.push(string)
      elsif @in_feature
        @property_features.push(string)
        #if feature is not in DB, adds to it.
        feature = PropertyFeature.find_by name: string
        if feature == nil
          PropertyFeature.create(name: string)
        end
      elsif @in_title
        @property_title = string
      elsif @in_description
        @property_description = string
      elsif @in_property_type
        @property_type_name = string
      elsif @in_name and @in_agent and @in_property
        @property_agent_name = string
      elsif @in_email and @in_agent and @in_property
        @property_agent_email = string
      elsif @in_cell and @in_agent and @in_property
        @property_agent_cell = string
      end
    end







    def end_element name, attrs = []
      case name
      when 'property'
        #search property in DB by its external_id
        property = Property.find_by external_id: @property_external_id
        if property == nil
          #adds a new property and publishes it
          property = Property.new
          property.external_id = @property_external_id
          property.published = true
          property.title = @property_title
          property.description = @property_description
          if @property_operation_type == 'sale'
            property.sale_price = @property_sale_price
            property.sale = true
          elsif @property_operation_type == 'rental'
            property.rent = @property_rent
            property.rental = true
          end
          if @property_currency != nil
            property.currency = @property_currency
          end
          property.bedrooms = @property_bedrooms
          property.bathrooms = @property_bathrooms
          property.parking_spaces = @property_parking_spaces

          @property_type = PropertyType.find_by  name: @property_type_name
          if @property_type == nil
#            puts 'Found a property type outside 4 types in seed.rb: '+@property_type_name
          else
            property.property_type = @property_type
          end
          
          if @has_agent
            @property_agent = User.find_by email: @property_agent_email
            if @property_agent == nil
              @property_agent = User.new
              @property_agent.email = @property_agent_email
              if @property_agent_name != nil
                @property_agent_name_count = @property_agent_name.scan(/\w+/).size
                if @property_agent_name_count >= 2
                  @property_agent.first_name = @property_agent_name.partition(" ").first
                  @property_agent.last_name = @property_agent_name.partition(" ").last
                else
                  @property_agent.first_name = @property_agent_name
                  @property_agent.last_name = @property_agent_name
                end
              end
              if @property_agent_cell != nil
                @property_agent.phone = @property_agent_cell
              end
              @property_agent.save
            end
          else
            @property_agent = User.find_by id: 1
            if @property_agent == nil
              @property_agent = User.create(id: 1, email: 'nino.bozzi@gmail.com', first_name: 'Nino', last_name: 'Bozzi', phone: '+56 9 92516664')
            end
          end
          property.user = @property_agent

          if @property_neighborhood != nil and @property_neighborhood != ''
            property.neighborhood = @property_neighborhood
            #save property if every required field is correct.

            #property.save
          end
        elsif
          #check updated date on DB. If same date as in xml, do nothing. Else, update property.
          puts "updated at: "+ property.updated_at
        end

        images_changed = false
        image_order = 1
        @property_images.each do |image_url|
          image = PropertyImage.find_by url: image_url
          if image == nil or image.order != image_order or image.property.external_id != property.external_id
            images_changed = true
          end
          image_order += 1
        end

        if images_changed
          #delete image list for this property
          PropertyImage.where(property: property).destroy_all
        end
        
        #create image list again for this property
        image_order = 1
        @property_images.each do |image_url|
          image = PropertyImage.find_by url: image_url
#          image = PropertyImage.create(url: image_url, order: image_order, property: property)         
          image_order += 1
        end
        
        #check if features in db are in feature names list
        feature_link_is_in_list = false
        links_in_db = PropertiesPropertyFeature.where(property: property)         #links in DB for this property
        links_in_db.each do |feature_link|
          @property_features.each do |feature_name|       #feature_name has the feature name from Internet
            if feature_link.property_feature.name == feature_name
              feature_link_is_in_list = true
            end
          end
          #if link is not in list, delete link
          if not feature_link_is_in_list
            feature_link.destroy
          end
        end


        @in_property = false
        @has_agent = false
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
      when 'bedrooms'
        @in_bedrooms = false
      when 'bathrooms'
        @in_bathrooms = false
      when 'parking_spaces'
        @in_parking_spaces = false
      when 'property_type'
        @in_property_type = false
      when 'name'
        @in_name = false
      when 'email'
        @in_email = false
      when 'cell'
        @in_cell = false
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
