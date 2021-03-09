class Api::V1::OrdersController < ApplicationController
  skip_before_action :authorized, only: [:create, :show, :index, :update]

  def index
    orders = Order.all
    render json: orders
  end

  def show
    orders = Order.all.select {|order| order.user_id === params[:id].to_i}
    render json: orders
  end

  def create
    order = Order.create(user_id: params[:user_id], pickup_date: params[:pickup_date], prepared: false, paid_for: false, picked_up: false)
    params[:wines].values.each do |wine|
      Item.create(order: order, wine: wine[:wine], quantity: wine[:quantity])
    end
  end

  def update
    order = Order.find(params[:id])
    order.update(prepared: params[:prepared], paid_for: params[:paid_for],
      picked_up: params[:picked_up])
    render json: order
  end

  private
  def user_params
    params.permit(:user_id, :wines, :pickup_date)
  end
end