class UserMailer < ApplicationMailer
  default from: 'lukenochetti@gmail.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: "bswan0002@gmail.com", subject: 'Welcome to King Lake Cellars')
  end
end
