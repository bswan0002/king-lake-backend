class Api::V1::CommitAdjustmentsController < ApplicationController
  skip_before_action :authorized, only: [:create, :show, :index, :update, :destroy]

  def index
    commit_adjustments = CommitAdjustment.all
    render json: commit_adjustments
  end

  def show
    commit_adjustments = CommitAdjustment.all.select {|commit_adjustment| commit_adjustment.user_id === params[:id].to_i}
    render json: commit_adjustments
  end

  def create
    commit_adjustment = CommitAdjustment.create(user_id: params[:user_id], adjustment: params[:adjustment],
    note: params[:note])
    render json: commit_adjustment
  end

  def destroy
    commit_adjustment = CommitAdjustment.find(params[:id])
    commit_adjustment.destroy
    render json: commit_adjustment
  end

  private
  def user_params
    params.permit(:user_id, :adjustment, :note)
  end
end