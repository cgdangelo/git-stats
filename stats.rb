require 'sinatra'
require 'sinatra/json'
require 'multi_json'
require 'coffee-script'
require 'yaml'
require 'haml'
require 'git'

config = YAML.load File.open("config.yml")
git = Git.open config['repository']['path']

get '/' do
  haml :stats
end

get '/js/app/stats.js' do
  coffee :stats, :bare => true
end

get '/branches/info.html' do
  haml :"branches/info"
end

get '/branches/list.html' do
  haml :"branches/list"
end

get '/branches' do
  branches = []
  git.branches.local.each do |branch|
    branches << branch.name
  end

  json branches
end

get '/branches/:branch' do
  commits = []
  git.gtree(params[:branch]).log.each do |commit|
    commits << {
      :sha => commit.sha[0, 7],
      :author => { :name => commit.author.name, :email => commit.author.email },
      :message => commit.message
    }
  end

  json commits
end

get '/js/app/branches.js' do
  coffee :"branches/branches", :bare => true
end

