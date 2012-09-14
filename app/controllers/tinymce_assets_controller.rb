class TinymceAssetsController < ApplicationController
  def create
    # Take upload from params[:file] and store it somehow...
    # Optionally also accept params[:hint] and consume if needed
    #Spree::Excel.new(params[:file])
    image = Spree::Excel.new(:attachment => params[:file])

    render json: {
        image: {
            url: view_context.image_url(image)
        }
    }, content_type: "text/html"
  end
end