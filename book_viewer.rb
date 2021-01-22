require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def in_paragraphs(content)
    result = ''
    each_paragraph(content) do |paragraph, index|
      result += "<p id=paragraph#{index}>#{paragraph}</p>\n"
    end
    result
  end

  def matching_paragraphs(match)
    result = ''
    query = match[:query]
    match[:matching_paragraphs].each do |match_data|
      paragraph_id = match_data[:index]
      content = match_data[:content].gsub(query, "<strong>#{query}</strong>")
      result += "<li><a href=\"chapters/#{match[:number]}#paragraph#{paragraph_id}\">"
      result += content + "</a></li>\n"
    end
    result
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

def each_paragraph(content)
  content.split("\n\n").each_with_index do |paragraph, index|
    yield paragraph, index
  end
end

def chapters_matching(query)
  search_results = []
  return search_results if query.nil? || query.empty?

  each_chapter do |number, title, contents|
    matching_paragraphs = []
    each_paragraph(contents) do |paragraph, index|
      matching_paragraphs << {index: index, content: paragraph} if paragraph.include?(query)
    end
    unless matching_paragraphs.empty?
      search_results << {number: number, title: title, 
                         matching_paragraphs: matching_paragraphs,
                         query: query}
    end
  end
  search_results
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
  @search_results = chapters_matching(@search_query)
  erb :search
end
