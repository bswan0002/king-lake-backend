class Api::V1::EventsController < ApplicationController
  skip_before_action :authorized, only: [:create, :show, :index, :update]

  def index
    events = Event.all
    render json: events
  end

  def show
    events = Event.find(params[:id])
    render json: events
  end

  def create
    event = Event.create(title: params[:title], date: params[:date],
    description: params[:description])
  end

  private
  def user_params
    params.permit(:title, :date, :description)
  end
end