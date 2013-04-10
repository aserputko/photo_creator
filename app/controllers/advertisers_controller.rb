class AdvertisersController < ApplicationController
 
  def create
    adv_number = params[:advertiser]
    adv_guid = Kigo.adv[adv_number.to_i] rescue nil
    adv_code = Kigo.brand[params[:brand]] rescue nil

    xml = Kigo.get_existing_properties_by_advertiser(adv_code, adv_guid)

    respond_to do |format|
      format.json { render json:  Kigo.get_account(adv_code, adv_guid)}
    end
  end
end