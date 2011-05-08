require "sinatra"
require "httparty"

class Lastfm
  include HTTParty
  base_uri "http://ws.audioscrobbler.com/2.0"


  def initialize(api_key, username)
    @api_key = api_key
    @username = username
  end

  def top_artists
    result = get_method("user.gettopartists")["topartists"]

    # if a user does not exist or if a user exists but has no tracks
    return [] if result.blank? || result["artist"].blank?

    result["artist"]
  end
  
  def get_method(method)
    self.class.get("?method=#{method}&user=#{@username}&api_key=#{@api_key}")["lfm"]
  end
end

class Soundtracks < Sinatra::Base
  set :root, File.expand_path(File.dirname(__FILE__))

  configure do
    @options = YAML.load_file(File.join(root, "soundtracks.yml"))
  end

  get "/" do
    erb :index
  end
  
  get "/search" do
    lastfm_username = params[:username]
    lastfm = Lastfm.new(@options["lastfm_key"], lastfm_username)
    artists = lastfm.top_artists
    erb :search, :locals => { :artists => artists, :username => lastfm_username }
  end
end
