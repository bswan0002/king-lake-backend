require 'square'

class Api::V1::SquareController < ApplicationController
  skip_before_action :authorized, only: [:customers]

  def customers
    client = Square::Client.new(
      access_token: Figaro.env.square_api_key,
      environment: 'production'
    )

    result = client.customers.search_customers(
      body: {
        limit: 100,
        query: {
          filter: {
            group_ids: {
              any: [
                "A0A1AAC7-FB31-4AFA-B6D6-572F68D5757D",
                "31937637-430C-4E4B-ADAF-CB4FE6CE816D"
              ]
            }
          },
          sort: {}
        }
      }
    )

    if result.success?
      puts result.data
      # member_groups = result.data[0].filter { |group|
      #   group[:name] === "Wine Club platinum" || group[:name] === "Wine Club gold"
      # }
      # puts member_groups
      # group_data = member_groups.map { |g| {id: g[:id], name: g[:name]} }
      # render json: group_data.to_json
    elsif result.error?
      render result.errors
    end
  end
end