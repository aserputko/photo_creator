require 'open-uri'
require 'fileutils'
require 'zip/zip'

class KigosController < ApplicationController

	def create
		adv_number = params[:advertiser]
    adv_guid = Kigo.adv[adv_number.to_i] rescue nil
    adv_code = Kigo.brand[params[:brand]]

    @sender = KigoApi::Sender.new
		remote_ids = @sender.get_all_kigo_ids		
		existing_properties = Kigo.get_existing_properties_by_advertiser adv_code, adv_guid

		FileUtils.rm_r("public/media/#{adv_number}") unless Dir["public/media/#{adv_number}"].empty?
		FileUtils.rm_r("public/media/#{adv_number}.zip") unless Dir["public/media/#{adv_number}.zip"].empty?
		Dir::mkdir("public/media/#{adv_number}")
		@image_urls = []
		existing_properties.each do |prop|
			next unless remote_ids.include?(prop["pro_external_id"].to_i)
			kigo_id = prop["pro_external_id"]
			ha_id = prop["pro_no"]

			get_all_images_by_kigo_id adv_number, kigo_id, ha_id
		end

		Zip::ZipFile.open("public/media/#{adv_number}.zip", Zip::ZipFile::CREATE) do |zipfile|
			ap "public/media/#{adv_number}.zip"
			@image_urls.each do |path|
				ap path
				puts zipfile.add(path.split("/").last, path)
			end
		end

		respond_to do |format|
      format.json { render json:  {"url" => "/media/#{adv_number}.zip"} }
    end
	end

	def get_existing_properties_by_advertiser adv_code, adv_guid
    properties  = []
    base_url = "https://api.homeaway.com"
    
    page = "#{adv_code}/#{adv_guid}/listingOnboardingSummary"
    ap  "Receiving existing properties from #{base_url + page}"
    begin
      xml = Nokogiri::XML RestClient.get(base_url + page)
      
      (xml/:listingOnboardingSummary).each do |summary|
        pro_no      = summary.at('listingNumber').text
        external_id = summary.at('externalId').text rescue nil
        
        property = {
          'pro_no'          => pro_no.to_i, 
          'pro_external_id' => external_id
        }
        
        properties << property
      end
      page = xml.at('nextPage').attr(:href) rescue nil
    end while page
    properties
  end

	def get_all_images_by_kigo_id adv_number, kigo_id, ha_id
		kigo = Kigo.find_by_kigo_id(kigo_id.to_s)
		@media_creator = KigoApi::MediaCreator.new(:production)
		if kigo.nil?
			begin
				media_collection = @media_creator.create_collection
				xml = Nokogiri::XML media_collection
				uuid = (xml/:uuid).text
				@sender = KigoApi::Sender.new
				kigo_listing = @sender.read_property kigo_id
				kigo_listing['PROP_PHOTOS'].each do |photo|
					ap "#{kigo_id}-#{photo['PHOTO_ID']}"
					img = @sender.read_property_photo_file(kigo_id, photo['PHOTO_ID'])
					@media_creator.create_media_item_from_original(uuid, Base64.decode64(img))
				end
				kigo = Kigo.create(:uuid => uuid, :kigo_id => kigo_id.to_s)
			rescue => e
				ap "#{e.message}"
				sleep(1)
				retry unless 5
				raise
			end
		end
		
		xml = Nokogiri::XML @media_creator.get_media_collection(kigo.uuid)
		position = 1
		(xml/:mediaItemRefs).map do |media_item|
			file_name = File.join("public/media/#{adv_number}/#{ha_id}-#{kigo_id}-#{position}.jpg")
			open(file_name, 'wb') do |file|
				img_url = "http://imagesus.homeaway.com/mda01/#{(media_item/:mediaItemUuid).text}.512.2"
				@image_urls << "public/media/#{adv_number}/#{ha_id}-#{kigo_id}-#{position}.jpg"
			  file << open(img_url).read
			  position += 1
			end	
		end
	end
end
