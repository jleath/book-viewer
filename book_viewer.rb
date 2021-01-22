require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

helpers do
  def in_paragraphs(content)
    content.split("\n\n")
           .map { |paragraph| "<p>#{paragraph}</p>" }
           .join
  end
end

not_found do
  redirect '/'
end

before do
  @chapter_list = File.readlines('data/toc.txt')
end

get "/" do
  @title = 'The Adventures of Sherlock Holmes'
  erb :home
end

get "/chapters/:chapter_number" do
  @chapter_list = File.readlines('data/toc.txt')
  @chapter_number = params[:chapter_number].to_i
  redirect '/' unless (1..@chapter_list.size).cover?(@chapter_number)
  @chapter_title = @chapter_list[@chapter_number]
  @title = "#{@chapter_number}: #{@chapter_title}"
  @paragraphs = File.read("data/chp#{@chapter_number}.txt")
  erb :chapter
end
