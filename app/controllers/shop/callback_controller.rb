require 'httparty'

class Shop::CallbackController < ApplicationController

  FB_VERIFY_TOKEN  = 'UKUKvzHHAg8gjXynx3hioFX7nC8KLa'
  FB_APP_ID        = '127037377498922'
  FB_APP_SECRET    = 'f88034e6df205b5aa3854e0b92638754'
  FB_CREDIT_AMOUNT = 30

  BYTRO_URL_BASE       = 'https://secure.bytro.com/index.php'
  BYTRO_SHARED_SECRET  = 'jfwjhgflhg254tp9824ghqlkgjh25pg8hgljkgh5896ogihdgjh24uihg9p8zgagjh2p895ghfsjgh312g09hjdfghj'
  BYTRO_KEY            = 'wackadoo'

  def fb_callback
    if params['hub.verify_token'] == FB_VERIFY_TOKEN
      render text: params['hub.challenge']
    else
      logger.debug "#{params}"

      payment_id = params['entry'] && params['entry'][0] && params['entry'][0]['id']

      if !payment_id.nil?
        response = HTTParty.get("https://graph.facebook.com/#{payment_id}", :query => {access_token: "#{FB_APP_ID}|#{FB_APP_SECRET}"})

        logger.debug "#{response}"

        if response.code == 200

          parsed_response = response.parsed_response
          action = parsed_response['actions'][0]

          logger.debug "#{parsed_response}"

          if action['status'] == 'completed'

            fb_user_id = parsed_response['user'] && parsed_response['user']['id']
            identity = Identity.find_by_fb_player_id(fb_user_id)

            unless identity.nil?
              data = {
                userID:      identity.identifier,
                method:      'bytro',
                offerID:     '248',
                scaleFactor: FB_CREDIT_AMOUNT.to_s,
                tstamp:      Time.now.to_i.to_s,
                comment:     '1',
                # comment: Base64.encode64(virtual_bank_transaction[:transaction_id].to_s).gsub(/[\n\r ]/,'')  # Hack!
              }

              query = {
                eID:    'api',
                key:    BYTRO_KEY,
                action: 'processPayment',
                data:   encoded_data(data),
              }

              query = add_hash(query)
              http_response = HTTParty.post(BYTRO_URL_BASE, :query => query)

              if http_response.code === 200
                api_response = http_response.parsed_response
                api_response = JSON.parse(api_response) if api_response.is_a?(String)
                if api_response['resultCode'] === 0
                  render json: :ok
                end
              end
            end
          end
        end
      end

      render json: :ok
    end
  end


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

  protected

    def self.encoded_data(data)
      url_encoded_data = {}
      data.each do |k, v|
        url_encoded_data[k] = CGI.escape(v)
      end
      base64_encoded_data = Base64.encode64(url_encoded_data.to_param)
      base64_encoded_data.gsub(/[\n\r ]/,'')
    end

    def self.add_hash(query)
      hash_base = query[:key] + query[:action] + CGI.escape(query[:data]) + BYTRO_SHARED_SECRET
      query[:hash] = Digest::SHA1.hexdigest(hash_base)
      query
    end

end
