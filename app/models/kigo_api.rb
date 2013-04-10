module KigoApi

	class Sender
	  def initialize
	  	@agent = Mechanize.new
	  	@agent.auth('homeaway', '1#93dKfU7h46')
	  	@api_url = 'https://app.kigo.net/api/ra/v1/'
	  end

	  def list_properties
	  	node = send_command 'listProperties'
	  	node.api_reply
	  end

	  def read_property prop_id
	  	node = send_command 'readProperty', { 'PROP_ID' => prop_id.to_i }
	  	node.api_reply
	  end

	  def read_property_photo_file(prop_id, photo_id)
			node = send_command 'readPropertyPhotoFile', {'PROP_ID' => prop_id.to_i, 'PHOTO_ID' => photo_id} 
			node.api_reply
		end

	  def send_command command, *args
	  	query = Hash[*args] if args.any?
	  	url = File.join([@api_url, command])

	  	response = nil
	  	with_retries(9) do
	  		response = @agent.post(url, query.to_json, {'Content-Type' => 'application/json'}).body
	  	end
	  	Node.new(response)
	  end

	  def get_all_kigo_ids
	  	urls_hash = {}
	  	list_properties.each do |property|
	  		urls_hash[property['PROP_ID']] = property['PROP_NAME']
	  	end
	  	urls_hash
	  end

	  def with_retries(num_retries = 4)
			begin
				yield
			rescue => e
				ap "Kigo error, wait #{num_retries -= 1}: #{e.message}"
				sleep(1)
				retry unless num_retries < 0
				raise
			end
		end
	end

	class Node
		attr_accessor :api_version, :api_revision, :api_method, :api_call_id, :api_result_code,
									:api_result_text,:api_reply, :api_deprecated

		def initialize(response_json)
			response_data = JSON.parse(response_json)
			response_data.each_pair do |k, v| 
				send("#{k.downcase}=", v) 
			end			
		end
	end

	class MediaCreator

		attr_reader :media_resource_server_url, :media_resource_server_type, :photo_v2_servers_url

		def initialize(server_type)
			media_resource_servers = {
    		:test => "http://media-resource-service-ustst1.wvrgroup.internal",
  			:stage => "http://media-resource-service-usstg1.wvrgroup.internal",
  			:production => "http://media-resource-service-usprd1.aus1.homeaway.live"
			}

  		@media_resource_server_url = media_resource_servers[server_type.to_sym]
  		@media_resource_server_type = server_type.to_sym
		end

		#  Create and return a new collection.
		def create_collection
			print "Create media clollection\n"
			response = RestClient.post getConnectionUrl(media_resource_server_url,'api/collections'), {}
			response.body
		end

		#  Upload image to media collection
		def create_media_item_from_original(uuid, file_url)
			print "Create media item\n"
			upload_file = open(file_url) rescue nil
			upload_file = file_url unless upload_file
			response = RestClient.post(getConnectionUrl(media_resource_server_url, 'api/collections', uuid, 'originals'), upload_file, :content_type => 'image/jpeg')
			response.body
		end

		#  Get the collection with UUID
		def get_media_collection(uuid)
			response = RestClient.get getConnectionUrl(media_resource_server_url,'api/collections', uuid)
			response.body
		end

		def getConnectionUrl(base_url, *args)
			[base_url, args].join('/')
		end
	end
end
