#Require Dependencies
require 'bundler/setup'
require 'pry'
require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "will_paginate"
require 'will_paginate/active_record'
require "will_paginate-bootstrap"
require './lib/auth'

#Require Models
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

#Configure Sinatra
set    :database, {adapter: "sqlite3", database: "./db/db.sqlite3"}
enable :sessions

#Controllers
get '/' do

  protected!

  #Get the current search
  search = params["search"]
  status = params["status"]

  #Get the list of todos
  @todos = Todo.paginate( :page => params[:page] , :per_page => 10 )

  #Search todos
  if search && !search.empty?
    @todos = @todos.where( "content LIKE :search" , search: "%#{search}%" )
  end

  #Filter by status
  if status && !status.empty?
    @todos = @todos.where( "status = :status" , status: status )
  end

  #Order Todos
  @todos = @todos.order( "status ASC , priority DESC" )

  #Render the view
  erb :list

end

post '/new' do

  protected!

  #Save new todo item
  begin

    #Save new todo item
    todo = Todo.new
    todo.content  = params["content"]
    todo.priority = params["priority"]
    todo.status   = 0
    todo.save!

    #Save success message to the session
    flash[:success] = "Successfully created new Todo Item"

  rescue ActiveRecord::RecordInvalid

      #Save success message to the session
      flash[:danger] = "There is an error with your data"
  end

  #Redirect to list
  redirect to("/")

end

get '/finish/:id' do

  protected!

  #Get the id from the request
  id = params["id"]

  #Find the todo item and change status
  todo = Todo.find id
  todo.status  = 1
  todo.save!

  #Redirect to list
  redirect to("/")

end

get '/unfinish/:id' do

  protected!

  #Get the id from the request
  id = params["id"]

  #Find the todo item and change status
  todo = Todo.find id
  todo.status  = 0
  todo.save!

  #Redirect to list
  redirect to("/")

end

get '/delete/:id' do

  protected!

  #Get the id from the request
  id = params["id"]

  #Delete the todo
  begin

    #Find the todo item
    todo = Todo.find id

    #Delete the todo
    todo.delete

    #Save success message to the session
    flash[:success] = "Successfully deleted item"

  rescue ActiveRecord::RecordNotFound

    #An error occured, show message
    flash[:danger] = "There was an error deleting todo list"

  end

  #Redirect to list
  redirect to("/")

end

get '/edit/:id' do

  protected!

  #Get the id from the request
  id = params["id"]

  #Find the todo item
  @todo = Todo.find id

  #Render the view
  erb :edit

end

post '/edit/:id' do

  protected!

  #Get the id from the request
  id = params["id"]

  #Find the todo item
  @todo = Todo.find id

  #Update its content
  begin

    #Update its content
    @todo.content  = params["content"]
    @todo.priority = params["priority"]
    @todo.save!

    #Redirect to list
    redirect "/"

  rescue ActiveRecord::RecordInvalid

      #Save success message to the session
      flash[:danger] = "There is an error with your data"

      #Redirect to list
      redirect to("/edit/" + id)

  end

end

get '/login' do
  erb :login
end

post '/login' do
  if authorize( nil )
    redirect to("/")
  else
      @error = "Invalid Username/Password"
  end
  erb :login
end

get '/logout' do
  logout!
end
