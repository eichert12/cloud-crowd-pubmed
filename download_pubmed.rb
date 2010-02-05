#!/usr/bin/env ruby -rubygems

require 'restclient'
require 'json'

# Let's count all the words in Shakespeare.
# 
RestClient.post('http://localhost:9173/jobs', 
  {:job => {
    'action' => 'pubmed',
    'inputs' => [
      "http://ftp.nlm.nih.gov/projects/medleasebaseline/zip/"
    ]
  }.to_json}
)

# With 23 Workers running, and over Wifi, it counted all the words in 5.5 secs.
# 
# require 'nokogiri'
# require 'zip/zipfilesystem'
# require 'open-uri'
# 
# input = "http://ftp.nlm.nih.gov/projects/medleasebaseline/zip/"
# doc = Nokogiri::HTML(open(input, :http_basic_authentication => ["eichert", "rjs@dpa7"]))
# files = doc.search("a").collect { |a| a.content.strip }.select {|url| url[-4, 4] == ".zip"}
# 
# input = input + files.first
# puts input
# 
# 
# open("./#{files.first}", 'wb') do |out|
#   out.write(open(input, :http_basic_authentication => ["eichert", "rjs@dpa7"]).read)
#   out.close
# end
# 
# xml_file = files.first.gsub(".zip", "")
# 
# unless File.exist?(xml_file)
#   Zip::ZipFile.foreach(files.first) do |entry|
#     entry.extract(xml_file)
#   end
# end
# 
# def val(node, element_name)
#   return "" if node.nil?
#   el = node.at_xpath(element_name)
#   el ? el.content : ""
# end
# 
# xml_file = "medline10n0001.xml"
# doc = Nokogiri::XML(open(xml_file)).search("/MedlineCitationSet/MedlineCitation").each do |citation|
#   puts "citation found...."
#   article = citation.at_xpath("Article")
#   pubdate = article.at_xpath("Journal/JournalIssue/PubDate")
#   authors = article.xpath("AuthorList/Author")
#   mesh_headings = citation.xpath("MeshHeadingList/MeshHeading")
#   keywords = citation.xpath("KeywordList/Keyword")
# 
#   article = { 
#     :pmid => val(citation, "PMID"),
#     :title => val(article, "ArticleTitle"),
#     :publication_date => {:year => val(pubdate, "Year"), :day => val(pubdate, "Day"), :month => val(pubdate, "Month") },
#     :authors => authors.collect {|author| {:last_name => val(author, "LastName"), :forename => val(author, "ForeName"), :initials => val(author, "Initials")} },
#     :publication_type => val(article.at_xpath("PublicationTypeList"), "PublicationType"),
#     :mesh_headings => mesh_headings.collect {|mesh| {:major_topic => val(mesh, "DescriptorName/@MajorTopicYN"), :heading => val(mesh, "DescriptorName")}},
#     :keywords => keywords.collect {|key| {:major_topic => val(key, "@MajorTopicYN"), :keyword => key.content }},
#     :journal => val(article.at_xpath("Journal"), "Title") 
#   }  
#   
#   puts article.to_json
# end
