require 'nokogiri'
require 'zip/zipfilesystem'
require 'open-uri'


#http://ftp.nlm.nih.gov/projects/medleasebaseline/index.html/zip/
class Pubmed < CloudCrowd::Action
  
  def split
    puts input
    doc = Nokogiri::HTML(open(input, :http_basic_authentication => ["eichert", "rjs@dpa7"]))
    doc.search("a").collect { |a| a.content.strip }.select {|url| url[-4, 4] == ".zip"}
  end

  def process
    url = "http://ftp.nlm.nih.gov/projects/medleasebaseline/zip/#{input.strip}"
    
    puts "downloading #{url}..."
    open("./#{input}", 'wb') do |out|
      out.write(open(url, :http_basic_authentication => ["eichert", "rjs@dpa7"]).read)
      out.close
    end


    xml_file = input.gsub(".zip", "")
    puts "extracting #{xml_file}..."
    unless File.exist?(xml_file)
      Zip::ZipFile.foreach(input) do |entry|
        entry.extract(xml_file)
      end
    end

    puts "reading xml file..."
    #xml_file = "medline10n0001.xml"
    doc = Nokogiri::XML(open(xml_file)).search("/MedlineCitationSet/MedlineCitation").collect do |citation|
      #puts "citation found...."
      article = citation.at_xpath("Article")
      pubdate = article.at_xpath("Journal/JournalIssue/PubDate")
      authors = article.xpath("AuthorList/Author")
      mesh_headings = citation.xpath("MeshHeadingList/MeshHeading")
      keywords = citation.xpath("KeywordList/Keyword")

      article = { 
        :pmid => val(citation, "PMID"),
        :title => val(article, "ArticleTitle"),
        :publication_date => {:year => val(pubdate, "Year"), :day => val(pubdate, "Day"), :month => val(pubdate, "Month") },
        :authors => authors.collect {|author| {:last_name => val(author, "LastName"), :forename => val(author, "ForeName"), :initials => val(author, "Initials")} },
        :publication_type => val(article.at_xpath("PublicationTypeList"), "PublicationType"),
        :mesh_headings => mesh_headings.collect {|mesh| {:major_topic => val(mesh, "DescriptorName/@MajorTopicYN"), :heading => val(mesh, "DescriptorName")}},
        :keywords => keywords.collect {|key| {:major_topic => val(key, "@MajorTopicYN"), :keyword => key.content }},
        :journal => val(article.at_xpath("Journal"), "Title") 
      }  

      article
    end.to_json
  end
  
  def val(node, element_name)
    return "" if node.nil?
    el = node.at_xpath(element_name)
    el ? el.content : ""
  end
  
  def merge
    input.each do |url|
      puts  url
#      download(batch_url, batch_path)
    end

#    save("processed_pdfs.tar")
  end
end
