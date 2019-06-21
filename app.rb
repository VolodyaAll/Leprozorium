#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'Leprozorium.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts
  (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    created_date DATE,
    content TEXT
  )'

  @db.execute 'CREATE TABLE IF NOT EXISTS Comments
  (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content TEXT,
    post_id INTEGER
  )'
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc'
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  @name = params[:name]
  @content = params[:content]

  hh = {:name => 'Enter your name',
  :content => 'Enter your message'}

  @error = hh.select{|key,_| params[key] == ""}.values.join(", ")

  return erb :new if @error != ''

  @db.execute 'insert into Posts (name, created_date, content) values (?, datetime(), ?)', [@name, @content]

  redirect to '/'
end

get '/detales/:post_id' do
  post_id = params[:post_id]

  results = @db.execute 'select * from Posts where id=?', [post_id]

  @row = results[0]

  @comments = @db.execute 'select * from Comments where post_id=? order by id', [post_id]

  erb :detales
end

post '/detales/:post_id' do
  post_id = params[:post_id]
  content = params[:content]

  if content.chomp.empty?
    @error = "Enter comment"

    results = @db.execute 'select * from Posts where id=?', [post_id]

    @row = results[0]

    @comments = @db.execute 'select * from Comments where post_id=? order by id', [post_id]

    erb :detales
  else
    @db.execute 'insert into Comments
      (
        created_date,
        content,
        post_id
      ) values
      (
        datetime(),
        ?,
        ?
      )', [content, post_id]

    redirect to '/detales/' + post_id
  end
end

