# NuviScript

Creates a redis list (NEWS_XML) of all news articles scraped from the endpoint.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nuvi_script', path: 'local/path/to/gem'
```

And then execute:

    $ bundle

## Usage

Run the script.
```
NuviScript.scrape
```

Or, interact with the Scrape class directly.
```
scraper = Scraper.new
scraper.process_zip_files 
```

Retrieve a news article by the zip folder name, and xml file name.
```
content = scraper.get_content_by_file_name(zip_folder_name, xml_file_name)
```

Retrieve all news articles
```
articles = scraper.get_news
```

Retrieve first news article
```
articles = scraper.get_news(0, 0)
```

Retrieve specific range of news article
```
articles = scraper.get_news(49, 99)
```

Clear all data that has been stored in redis by the scraper.
```
scraper.flush_lists!
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

