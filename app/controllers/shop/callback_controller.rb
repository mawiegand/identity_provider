require 'httparty'

class Shop::CallbackController < ApplicationController

  def redirect

    logger.debug "POST PARAMS " + request.request_parameters.inspect

    # redirect callbacks for offerID 761 (special offer) to production game server
    if !params[:offerID].nil? && params[:offerID] == '761'

      response = HTTParty.post('https://gs02.wack-a-doo.de/game_server/shop/special_offers_transactions',
                             :body => request.request_parameters,
                             :headers => { 'Accept' => 'application/json'})

      if response.code == 201
        # send 201 for successful callback on
        render json: {:status => 'special offer processed'}, status: :created
      else
        # if not successful, send response code and message provided by game server
        render json: {:status => response.message}, status: response.code
      end
    else
      # send 201 for unknown offerIDs to prevent continuous retrying of callbacks
      render json: {:status => 'unknown offerID'}, status: :created
    end
  end
end
