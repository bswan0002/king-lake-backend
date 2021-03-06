class Api::V1::OrdersController < ApplicationController
  skip_before_action :authorized, only: [:create, :show, :index]

  def index
    orders = Order.all
    render json: orders
  end

  def show
    orders = Order.all.select {|order| order.user_id === params[:id].to_i}
    render json: orders
  end

  def create
    order = Order.create(user_id: params[:user_id], prepared: false, paid_for: false, picked_up: false)
    params[:wines].values.each do |wine|
      Item.create(order: order, wine: wine[:wine], quantity: wine[:quantity])
    end
  end

  private
  def user_params
    params.permit(:user_id, :wines, :pickup_date)
  end
end