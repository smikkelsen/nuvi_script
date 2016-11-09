require 'redis'
require 'nokogiri'
require 'open-uri'
require 'tmpdir'
require 'zip'
require 'ruby-progressbar'

class Scraper

  ROOT_URL = 'http://bitly.com/nuvi-plz'
  ZIP_FILE_KEY = 'ZIP_FILES'
  XML_FILE_KEY = 'XML_FILES'
  NEWS_XML_KEY = 'NEWS_XML'
  MAX_CONCURRENT_THREADS = 2

  def process_zip_files
    pb = ProgressBar.create({title: 'Zip Files', total: urls.length, remainder_mark: '.', format: '%a |%b>>%i| %p%% %t'})
    urls.each_slice(MAX_CONCURRENT_THREADS) do |group|
      thread_list = [] #keep track of our threads
      group.each do |zip_file_name, url|
        thread_list << Thread.new {
          get_zip_file(zip_file_name, url)
          pb.increment
        }
      end
      thread_list.each { |x| x.join }
    end

  end

  def get_content_by_file_name(zip_name, file_name)
    file_name.gsub!('.xml', '')
    index = redis.hget("#{XML_FILE_KEY}:#{zip_name}", file_name)
    unless index.nil?
      redis.lindex(NEWS_XML_KEY, index)
    end
  end

  def flush_lists!
    redis.del ZIP_FILE_KEY
    redis.del XML_FILE_KEY
    redis.del NEWS_XML_KEY
  end

  def get_news(i1=0, i2=-1)
    redis.lrange(NEWS_XML_KEY, i1, i2)
  end

  private

  def redis
    @redis ||= Redis.new(timeout: 5)
  end

  def urls
    if @urls.nil?
      redirect_url = open(ROOT_URL).base_uri.to_s
      doc = Nokogiri::HTML(open(redirect_url))
      @urls = doc.css('a').select { |link| link.text.include? '.zip' }.map { |link| [link.text.gsub('.zip', ''), "#{redirect_url}#{link['href']}"] }
    end
    @urls
  end

  def previously_processed_zip?(file_name)
    !(redis.hget(ZIP_FILE_KEY, file_name)).nil?
  end

  def previously_processed_xml?(zip_name, file_name)
    !(redis.hget("#{XML_FILE_KEY}:#{zip_name}", file_name)).nil?
  end

  def get_zip_file(zip_file_name, url)
    unless previously_processed_zip?(zip_file_name)
      open(url) do |zip_file|
        process_xml_files(zip_file_name, zip_file)
      end
      redis.hset(ZIP_FILE_KEY, zip_file_name, Time.now)
    end
  end

  def process_xml_files(zip_file_name, zip_file)
    Zip::File.open(zip_file.path) do |zip_folder|
      zip_folder.each do |entry|
        process_xml_file(zip_file_name, entry)
      end
    end
  end

  def process_xml_file(zip_file_name, xml_file)
    xml_file_name = xml_file.to_s.gsub('.xml', '')
    unless previously_processed_xml?(zip_file_name, xml_file_name)
      contents = xml_file.get_input_stream { |is| is.read }
      xml_file_index = (redis.rpush NEWS_XML_KEY, contents) - 1
      redis.hset("#{XML_FILE_KEY}:#{zip_file_name}", xml_file_name, xml_file_index)
    end
  end

end