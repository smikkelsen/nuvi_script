require "nuvi_script/scraper"
require "nuvi_script/version"

module NuviScript
  def self.scrape
    s = Scraper.new
    s.process_zip_files
  end
end
