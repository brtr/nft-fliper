class UsersController < ApplicationController
  def login
    user = User.where(address: params[:address]).first_or_create
    session[:user_id] = user.id
    is_subscribed = Time.now < user.subscription_date rescue false

    render json: {success: true, is_subscribed: is_subscribed}
  end

  def logout
    session[:user_id] = nil if session[:user_id]

    render json: {success: true}
  end

  def subscribe
    user = User.find_by id: session[:user_id]
    if user
      user.subscription_date = Time.now + params[:month].to_i.months
      user.save

      render json: {is_subscribed: Time.now < user.subscription_date}
    end
  end

  def stake_token
    user = User.find_by id: session[:user_id]
    if user
      user.user_points.create(staking_time: Time.now)

      render json: {success: true}
    end
  end

  def claim_token
    user = User.find_by id: session[:user_id]
    if user
      up = user.user_points.where(claim_time: nil).take
      if up
        time = Time.now
        points = (time - up.staking_time) / 3600
        up.update(claim_time: Time.now, points: points)
        user.update(points: user.points + points)
      end

      render json: {success: true, points: up.points}
    end
  end
end
