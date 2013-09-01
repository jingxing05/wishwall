# coding:utf-8
require 'sinatra'
require 'bundler'
Bundler.require
if ENV['VCAP_SERVICES'].nil?
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/development.db")
else
    require 'json'
    svcs = JSON.parse ENV['VCAP_SERVICES']
    mysql = svcs.detect { |k,v| k =~ /^mysql/ }.last.first
    creds = mysql['credentials']
    user, pass, host, name = %w(user password host name).map { |key| creds[key] }
    DataMapper.setup(:default, "mysql://#{user}:#{pass}@#{host}/#{name}")
end

class Topic
    include DataMapper::Resource
    property :id, Serial
    property :subject, String, :required => true
    has n, :wishs, :constraint => :destroy
end

#Wish.create(from:'qingfeng', to:'linxinru', wish:'want fuck u every day', mtime:Time.now.strftime("%y年%m月%d日 %H点%M分"),topic_id:1)

class Wish
    include DataMapper::Resource
    property :id,    Serial 
    property :from,  String, :required => true, :length => 1..9
    property :to,    String, :required => true, :length => 1..9
    property :wish,  String, :required => true, :length => 1..140
    property :mtime, String, :required => true
    belongs_to :topic
end
DataMapper.finalize

# automatically create the post table
Wish.auto_upgrade!


# show all wishes 
get '/' do
    @wishes = Wish.all(:order => [ :mtime.desc ])
    erb:index
end


post '/' do
    @cwish = Wish.create(
                        :from=>params['wishfrom'], 
                        :to=>params['wishto'],
                        :wish=>params['wishcontent'],
                        :mtime=>Time.now.strftime("%Y-%m-%d %H:%M"),
                        :topic_id=>1)
    "#{@cwish.saved?}"
end
 
get '/p' do 
    erb:pubu
end