# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "seeding"

# client = Square::Client.new(
#   access_token: Figaro.env.square_api_key,
#   environment: 'production'
# )

# members = User.select {|u| u.square_id && u.roles.any? {|r| r.role_type === "member"}}

# members.each do |member|
#   result = client.customers.retrieve_customer(
#     customer_id: member.square_id
#   )
  
#   if result.success?
#     months = ((Time.now - DateTime.rfc3339(result.data[0][:created_at]))/2628000).round
#     p "#{result.data[0][:given_name]} #{result.data[0][:family_name]}"
#     if result.data[0][:groups].any? {|g| g[:name] === "Wine Club gold"}
#       member.update(commit_count: months)
#     else
#       member.update(commit_count: months*2)
#     end
#     p member.commit_count
#   elsif result.error?
#     warn result.errors
#   end
# end