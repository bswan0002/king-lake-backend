require 'square'

class Api::V1::SquareController < ApplicationController
  skip_before_action :authorized, only: [:customers, :show, :wines]

  def wines
    client = Square::Client.new(
      access_token: Figaro.env.square_api_key,
      environment: 'production'
    )

    result = client.catalog.list_catalog(
      types: "ITEM"
    )
    
    if result.success?
      wines = result.data[0].filter {|item| item[:item_data][:name].start_with?("20")}
      wine_data = wines.map do |wine|
        price = wine[:item_data][:variations][0][:item_variation_data][:price_money][:amount]
        {
          "name": wine[:item_data][:name],
          "price": price
        }
      end
      render json: wine_data.to_json
    elsif result.error?
      warn result.errors
    end
  end

  def show
    client = Square::Client.new(
      access_token: Figaro.env.square_api_key,
      environment: 'production'
    )

    result = client.customers.retrieve_customer(
      customer_id: params[:id]
    )
    
    if result.success?
      # determine membership level
      if result.data[0][:groups].any? {|g| g[:name] === "Wine Club gold"}
        membership = "Gold"
      else
        membership = "Platinum"
      end
      # organize desired data from Square response
      square_data = {
        "square_id": result.data[0][:id],
        "created_at": result.data[0][:created_at],
        "given_name": result.data[0][:given_name],
        "family_name": result.data[0][:family_name],
        "email": result.data[0][:email_address],
        "phone_number": result.data[0][:phone_number],
        "membership_level": membership
      }

      transactions = client.orders.search_orders(
        body: {
          location_ids: [
            "EBB8FHQ6NBGA8"
          ],
          query: {
            filter: {
              customer_filter: {
                customer_ids: [
                  square_data[:square_id]
                ]
              }
            }
          }
        }
      )
      if transactions.success?
        #byebug
        t_data = []
          transactions.data && transactions.data[0].each do |t|
            if t[:line_items] && t[:line_items].any? {|li| li[:name] && li[:name].start_with?("20")}
              items = t[:line_items].reject{|li| !li[:name].start_with?("20")}.map { |li| { uid: li[:uid],
                 catalog_object_id: li[:catalog_object_id], quantity: li[:quantity], name: li[:name]} }
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

      # look up user in our DB
      currentUser = User.find {|u| u.square_id === result.data[0][:id]}

      member_data = {
        "square": square_data,
        "db": {
          "id": currentUser.id,
          "commit_count": currentUser.commit_count,
          "commit_adjustments": currentUser.commit_adjustments
        },
        "transactions": t_data
      }

      render json: member_data.to_json
    elsif result.error?
      warn result.errors
    end
  end

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
      filtered = result.data[0].map {|m| {"square_id": m[:id], "created_at": m[:created_at], "given_name": m[:given_name],
        "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
        "membership_level": "Platinum"} }
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
          result.data[0].each {|m| filtered << {"square_id": m[:id], "created_at": m[:created_at], "given_name": m[:given_name],
            "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
            "membership_level": "Platinum"} }
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
      gold_result.data[0].each {|m| filtered << {"square_id": m[:id], "created_at": m[:created_at],  "given_name": m[:given_name],
        "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
        "membership_level": "Gold"} }
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
          gold_result.data[0].each {|m| filtered << {"square_id": m[:id], "created_at": m[:created_at], "given_name": m[:given_name],
            "family_name": m[:family_name], "email": m[:email_address], "phone_number": m[:phone_number],
            "membership_level": "Gold"} }
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
        p member[:membership_level]
        member[:membership_level] === "Gold" ? count = 1 : count = 2
        currentUser = User.create(email: member[:email], password: "d3vp4ss", square_id: member[:square_id], commit_count: count)
        Role.create(role_type: "member", user_id: currentUser.id)
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
            if t[:line_items] && t[:line_items].any? {|li| li[:name] && li[:name].start_with?("20")}
              items = t[:line_items].reject{|li| li[:name] && !li[:name].start_with?("20")}.map { |li| { uid: li[:uid],
                 catalog_object_id: li[:catalog_object_id], quantity: li[:quantity], name: li[:name]} }
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
          "commit_count": currentUser.commit_count,
          "commit_adjustments": currentUser.commit_adjustments
        },
        "transactions": t_data
      }
    end
    render json: results.to_json
  end
end