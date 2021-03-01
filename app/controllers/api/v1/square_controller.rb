require 'square'

class Api::V1::SquareController < ApplicationController
  skip_before_action :authorized, only: [:customers]

  def customers
    client = Square::Client.new(
      access_token: Figaro.env.square_api_key,
      environment: 'production'
    )
    plat_id = "31937637-430C-4E4B-ADAF-CB4FE6CE816D"
    gold_id = "A0A1AAC7-FB31-4AFA-B6D6-572F68D5757D"

    # initial plat query
    result = client.customers.search_customers(
      body: {
        limit: 20,
        query: {
          filter: {
            group_ids: {
              any: [
                plat_id
              ]
            }
          },
          sort: {}
        }
      }
    )

    # {"customers": [
    #   {
    #     "id": "DDMAZ5X1HX3T719477BRM31WAC",
    #     "given_name": "Amy",
    #     "family_name": "Scott",
    #     "email_address": "ALS98053@hotmail.com",
    #     "phone_number": "(425) 894-4488",
    #     "preferences": {
    #       "email_unsubscribed": false
    #     },
    #     "groups": [
    #       {
    #         "id": "31937637-430C-4E4B-ADAF-CB4FE6CE816D",
    #         "name": "Wine Club platinum"
    #       },
    #     ],
    #   },
    #  ]
    #  "cursor": "long_cursor_string"
    # }
    # result.cursor returns cursor string if there is one, else returns nil

    if result.success?
      filtered = result.data[0].map {|m| {"square_id": m[:id], "given_name": m[:given_name],
        "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
        "membership_level": "platinum"} }
      while result.cursor
        result = client.customers.search_customers(
          body: {
            cursor: result.cursor,
            limit: 20,
            query: {
              filter: {
                group_ids: {
                  any: [
                    plat_id
                  ]
                }
              },
              sort: {}
            }
          }
        )

        if result.success?
          result.data[0].each {|m| filtered << {"square_id": m[:id], "given_name": m[:given_name],
            "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
            "membership_level": "platinum"} }
        elsif result.error?
          render result.errors
        end
      end
      # member_groups = result.data[0].filter { |group|
      #   group[:name] === "Wine Club platinum" || group[:name] === "Wine Club gold"
      # }
      # puts member_groups
      # group_data = member_groups.map { |g| {id: g[:id], name: g[:name]} }
      # render json: group_data.to_json
    elsif result.error?
      render result.errors
    end

    gold_result = client.customers.search_customers(
      body: {
        limit: 20,
        query: {
          filter: {
            group_ids: {
              any: [
                gold_id
              ]
            }
          },
          sort: {}
        }
      }
    )

    if gold_result.success?
      gold_result.data[0].each {|m| filtered << {"square_id": m[:id], "given_name": m[:given_name],
        "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
        "membership_level": "gold"} }
      while gold_result.cursor
        gold_result = client.customers.search_customers(
          body: {
            cursor: gold_result.cursor,
            limit: 20,
            query: {
              filter: {
                group_ids: {
                  any: [
                    gold_id
                  ]
                }
              },
              sort: {}
            }
          }
        )

        if gold_result.success?
          gold_result.data[0].each {|m| filtered << {"square_id": m[:id], "given_name": m[:given_name],
            "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
            "membership_level": "gold"} }
        elsif gold_result.error?
          render gold_result.errors
        end
      end
      # member_groups = result.data[0].filter { |group|
      #   group[:name] === "Wine Club platinum" || group[:name] === "Wine Club gold"
      # }
      # puts member_groups
      # group_data = member_groups.map { |g| {id: g[:id], name: g[:name]} }
      # render json: group_data.to_json
    elsif gold_result.error?
      render gold_result.errors
    end

    results = []
    stop = false

    filtered.each do |member|
      currentUser = User.find {|u| u.square_id === member[:square_id]}
      if !currentUser
        currentUser = User.create(email: member[:email], password: "d3vp4ss", square_id: member[:square_id], commit_count: 24)
        Role.create(role_type: "member", user: newUser)
      end

      transactions = client.orders.search_orders(
        body: {
          location_ids: [
            "EBB8FHQ6NBGA8"
          ],
          query: {
            filter: {
              customer_filter: {
                customer_ids: [
                  member[:square_id]
                ]
              }
            }
          }
        }
      )
      if transactions.success?
        t_data = []
          transactions.data && transactions.data[0].each do |t|
            if t[:line_items]
              items = t[:line_items].map { |li| { uid: li[:uid], catalog_object_id: li[:catalog_object_id], 
                quantity: li[:quantity], name: li[:name]} }
            end
            
            t_obj = {
              id: t[:id],
              created_at: t[:created_at],
              line_items: items,
            }
            t_data << t_obj
          end
      elsif transactions.error?
        warn transactions.errors
      end

      results << {
        "square": member,
        "db": {
          "id": currentUser.id,
          "commit_count": currentUser.commit_count
        },
        "transactions": t_data
      }
    end
    pp results
    render json: results.to_json
  end
end