require 'rubygems'
require 'sinatra'
require 'haml'
require 'redcloth'
require 'sinatra_more/markup_plugin'

Sinatra::Base.register SinatraMore::MarkupPlugin

before do
  content_type 'text/html', :charset => 'utf-8'
end

get '/' do
  @page = params[:page] || 'FrontPage'
  filename = filepath(@page)
  if File.exist? filename
    dat = File.open(filename).read
    @content = RedCloth.new(dat).to_html
    haml :show
  else
    haml :edit
  end
end

get '/list' do
  @files = Dir.glob("#{datadir}/*#{dataext}")
  haml :list
end

get '/edit' do
  @content = File.open(filepath(params[:page])).read rescue nil
  haml :edit
end

put '/' do
  FileUtils.mkdir_p(datadir) unless File.exist? datadir
  File.open(filepath(params[:page]), 'w') do |file|
    file.puts params[:body]
  end
  redirect "/?page=#{params[:page]}"
end

private
def datadir
  'data'
end

def dataext
  '.txt'
end

def filepath(name)
  File.join(datadir, name + dataext)
end
