require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

helpers do
  def in_paragraphs(content)
    content.split("\n\n").each_with_index.map do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}</p>"
    end.join
  end
end

not_found do
  redirect '/'
end

before do
  @chapter_list = File.readlines('data/toc.txt')
end

def each_chapter
  @chapter_list.each_with_index do |title, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, title, contents
  end
end

def chapters_matching(query)
  matches = []
  return matches if query.nil? || query.empty?

  each_chapter do |number, title, contents|
    matches << {number: number, title: title} if contents.include?(query)
  end

  matches
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

get "/search" do
  @title = 'The Adventures of Sherlock Holmes'
  @search_query = params[:query]
  @matches = chapters_matching(@search_query)
  erb :search
end
