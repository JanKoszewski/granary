class Api::V1::TreesController < ApplicationController

	def show
    @seed = Seed.find(params["id"])
    unless @seed
      render :json => {error: "The specified seed does not exist."}, :status => :not_found
    end
  end
end
