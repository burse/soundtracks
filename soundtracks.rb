require 'sinatra'

get "/" do
  erb :index
end

get "/search" do
  username = params[:username]
  "Hi #{username}!"
end
