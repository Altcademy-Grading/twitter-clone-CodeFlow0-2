class TweetsController < ApplicationController
  before_action :set_tweet, only: [:destroy]

  def create
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)
    current_user = session.user if session

    @tweet = current_user.tweets.build(tweet_params)

    if @tweet.save
      render json: @tweet, status: :created
    else
      render json: { errors: @tweet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)
    current_user = session.user if session

    if @tweet.user == current_user
      @tweet.destroy
      render json: { message: 'Tweet deleted successfully' }
    else
      render json: { error: 'Unauthorized to delete this tweet' }, status: :unauthorized
    end
  end

  def index
    @tweets = Tweet.all
    render json: @tweets
  end

  def index_by_user
    @user = User.find_by(username: params[:username])

    if @user
      @tweets = @user.tweets
      render json: @tweets
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:message)
  end

  def set_tweet
    @tweet = Tweet.find(params[:id])
  end
end
