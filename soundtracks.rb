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
    result.blank? || result["artist"].blank? ?
      [] :
      result["artist"]
  end
  
  def get_method(method)
    self.class.get("?method=#{method}&user=#{@username}&api_key=#{@api_key}")["lfm"]
  end
end

class Soundtracks < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :settings_file_path, File.join(root, "soundtracks.yml")

  # returns a hash containing settings loaded from the environment if they're present, null otherwise
  def self.load_settings_from_env
    lastfm_api_key = ENV["LASTFM_API_KEY"]
    { :lastfm_api_key => lastfm_api_key } unless lastfm_api_key.blank?
  end

  # returns a hash containing settings loading from the .yml file if it's present, null otherwise
  def self.load_settings_from_file
    YAML.load_file(settings_file_path) if File.exists?(settings_file_path)
  end

  # returns a hash containing settings (loaded from the settings file or the environment)
  def self.load_settings
    # try the settings file, then the env if that didn't work
    settings = load_settings_from_file
    settings = load_settings_from_env if settings.blank?
    # no settings available, raise an error
    raise "No application settings available" if settings.blank?
    settings
 end

  configure do
    # make the settings available to all routes
    set self.load_settings
  end

  get "/" do
    erb :index
  end
  
  get "/search" do
    lastfm_username = params[:username]
    lastfm = Lastfm.new(settings.lastfm_api_key, lastfm_username)
    artists = lastfm.top_artists
    erb :search, :locals => { :artists => artists, :username => lastfm_username }
  end
end
