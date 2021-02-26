require 'square'

class Api::V1::SquareController < ApplicationController
  skip_before_action :authorized, only: [:customers]

  def customers
    client = Square::Client.new(
      access_token: Figaro.env.square_api_key,
      environment: 'production'
    )

    result = client.customer_groups.list_customer_groups

    byebug

    if result.success?
      puts result.data
    elsif result.error?
      warn result.errors
    end
  end
end