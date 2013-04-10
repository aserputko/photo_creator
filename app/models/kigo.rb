class Kigo < ActiveRecord::Base
  attr_accessible :ha_id, :kigo_id, :uuid


  #HARDCODE
  def self.adv
    {
      206910  => '48e0da8e-7994-422b-aa4f-bb49f061ff35',
      1085729 => '7c21919e-909f-419e-9dea-7cbdff80245c',
      645572  => '7f957cc8-93df-41a8-a4e2-dc3c6bc8655b',
      168626  => 'b788a99f-3b1e-4e20-92cb-de8cf86b803b',
      640031  => 'fe95bd77-6af9-4e47-a812-abfc4a9c2064',
      1063949 => 'ceaf84cd-24c3-439a-a50d-240c59cfec4f'
    }
  end

  def self.brand
  	{
  		'ha' => '/advertisers/0020',
			'hr' => '/advertisers/0021',
		  'vv' => '/advertisers/0022',
		  'ab' => '/advertisers/0023'  
		}
  end

  def self.get_account adv_code, adv_guid
    base_url = "https://api.homeaway.com"
    page = "#{adv_code}/#{adv_guid}"
    xml = Nokogiri::XML RestClient.get(base_url + page)

    email = {
      'email' => (xml/:email).text,
      'first_name' => (xml/:firstName).text,
      'last_name' => (xml/:lastName).text
    }
  end

  def self.get_existing_properties_by_advertiser adv_code, adv_guid
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
end
