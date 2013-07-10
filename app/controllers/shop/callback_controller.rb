require 'httparty'

class Shop::CallbackController < ApplicationController

  def redirect
    response = HTTParty.post('https://localhost/game_server/shop/special_offers_transactions/new',
                             :body => {:offerID => '4711', :partnerUserID => 'OGvYwFVEMESYXCLT'},
                             :headers => { 'Accept' => 'application/json'})

    render json: {:status => 'created'}, status: :created
  end

end
