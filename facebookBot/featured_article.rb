require 'wikipedia_rest_client'
require 'date'

# @author Balaji
class MessengerBot


	# @param text [string] The text in which HTML tags need to be removed
	# @return [string] HTML tag free text
	# This method is used to remove tags like <i>,<b> from the text
	#
	def self.remove_tags(text)
		text.gsub!("/","")
		text.gsub!(/<[a-z]*>/,"")
		return text
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @return [nil]
	# This method is used to get featured article of the day content from Wikipedia
	#
	def self.get_today_featured_article(id)
		language = get_language(id)
		WikipediaRestClient.set_language(language)
		begin
			today_featured_article = WikipediaRestClient.get_featured_article
			title = today_featured_article.title
			url = today_featured_article.url
			thumbnail_url = today_featured_article.thumbnail_source if today_featured_article.thumbnail_source
			thumbnail_url = WIKIPEDIA_LOGO unless  today_featured_article.thumbnail_source
			text = today_featured_article.text
		rescue
			WikipediaRestClient.set_language("en")
			today_featured_article = WikipediaRestClient.get_featured_article
			title = today_featured_article.title
			url = today_featured_article.url
			thumbnail_url = today_featured_article.thumbnail_source if today_featured_article.thumbnail_source
			thumbnail_url = WIKIPEDIA_LOGO unless  today_featured_article.thumbnail_source
			text = today_featured_article.text
		end
		template = GENERIC_TEMPLATE_BODY
		title = remove_tags(title)
		template[:attachment][:payload][:elements] = [{
            "title": title,
            "subtitle": text,
            "image_url": thumbnail_url,
            "default_action": {
        		"type": "web_url",
        		"url": url
      		},
            "buttons":[
            	{
              		"type": "web_url",
              		"title": READ_MORE_BUTTON["#{language}"],
              		"url": url
            	}
        	]      
        }]
		post_template(id,template)
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @return [nil]
	# It is used to fetch 'Image of the day' from Wikipedia and post it to the user's Messenger chat.
	#
	def self.get_image_of_the_day(id)
		language = get_language(id)
		WikipediaRestClient.set_language(language)
		begin
			image = WikipediaRestClient.get_image_of_the_day
			title = image.title
			thumbnail_url = image.thumbnail
			image_commons_page = COMMONS_IMAGE_PAGE_BASE_URL + title
			text = image.description_text
		rescue  
			WikipediaRestClient.set_language("en")
			image = WikipediaRestClient.get_image_of_the_day
			title = image.title
			thumbnail_url = image.thumbnail
			image_commons_page = COMMONS_IMAGE_PAGE_BASE_URL + title
			text = image.description_text
		end
		template = GENERIC_TEMPLATE_BODY
		title = remove_tags(title)
		template[:attachment][:payload][:elements] = [{
            "title": title,
            "subtitle": text,
            "image_url": thumbnail_url,
            "default_action": {
        		"type": "web_url",
        		"url": image_commons_page
      		},
            "buttons":[
            	{
              		"type": "web_url",
              		"title": VIEW_ON_BROWSER_BUTTON["#{language}"],
              		"url": image_commons_page
            	}
        	]      
        }]
		post_template(id,template)
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @return [nil]
	# The method used to fetch 'On this day' contents from Wikipedia.
	#
	def self.get_on_this_day(id)
		language = get_language(id)
		WikipediaRestClient.set_language(language)
		date = Time.now.strftime("%Y/%m/%d")
		begin
			on_this_day_content = WikipediaRestClient.get_on_this_day
			raise 'NilClassException' if on_this_day_content == nil
		rescue  
			WikipediaRestClient.set_language("en")
			on_this_day_content = WikipediaRestClient.get_on_this_day
		end
		template = GENERIC_TEMPLATE_BODY
		elements = []
		(0..9).each { |i|
			break if i > on_this_day_content.length-1
			text =  on_this_day_content[i]["text"]
			year = on_this_day_content[i]["year"]
			new_element = {
					"title": "On #{year}",
		            "subtitle": text,
		            "buttons":[
		            	{
		              		"type": "postback",
		              		"title": GET_SUMMARY_BUTTON["#{language}"],
		              		"payload": "GET_ON_THIS_DAY_SUMMARY_#{i}_#{date}"  # Add date value with the payload
		            	}
		            ]
		    }
		    elements << new_element		
		}
		template[:attachment][:payload][:elements] = elements
		post_template(id,template)
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @return [nil]
	# This method used to get the most_read contents of Wikipedia.
	#
	def self.get_most_read(id)
		language = get_language(id)
		WikipediaRestClient.set_language(language)
		begin
			most_read = WikipediaRestClient.get_most_read
			raise 'NilClassException' if most_read == nil
		rescue  
			WikipediaRestClient.set_language("en")
			most_read = WikipediaRestClient.get_most_read
		end
		template = GENERIC_TEMPLATE_BODY
		elements = []
		(0..9).each { |i|
			break unless most_read 
			break if i > most_read["articles"].length-1
			title =  remove_tags(most_read["articles"][i]["displaytitle"])
			text = most_read["articles"][i]["extract"]
			thumbnail_url = most_read["articles"][i]["thumbnail"]["source"] if most_read["articles"][i]["thumbnail"]
			thumbnail_url = WIKIPEDIA_LOGO unless most_read["articles"][i]["thumbnail"]
			url = most_read["articles"][i]["content_urls"]["desktop"]["page"]
			new_element = {
					"title": title,
		            "subtitle": text,
		            "image_url": thumbnail_url,
		            "default_action": {
        				"type": "web_url",
        				"url": url
      				},
		            "buttons":[
		            	{
		              		"type": "web_url",
		              		"title": READ_MORE_BUTTON["#{language}"],
		              		"url": url
		            	}
        			] 
		    }
		    elements << new_element		
		}
		if elements.length != 0 then
			template[:attachment][:payload][:elements] = elements
			post_template(id,template)
		else
			say(id, NO_MOST_READ_CONTENT_MESSAGE["#{language}"])
		end
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @return [nil]
	# This method used to get news contents and post it to user's Messenger chat.
	#
	def self.get_news(id)
		language = get_language(id)
		WikipediaRestClient.set_language(language)
		date = Time.now.strftime("%Y/%m/%d")
		begin
			news = WikipediaRestClient.get_news
			raise 'NilClassException' if news == nil
		rescue  
			WikipediaRestClient.set_language("en")
			news = WikipediaRestClient.get_news
		end
		template = GENERIC_TEMPLATE_BODY
		elements = []
		(0..9).each { |i|
			break if i > news.length-1

			text =  news[i]["story"]
			new_element = {
		            "title": text,
		            "buttons":[
		            	{
		              		"type": "postback",
		              		"title": GET_SUMMARY_BUTTON["#{language}"],
		              		"payload": "GET_NEWS_SUMMARY_#{i}_#{date}"  # Add date value with the payload
		            	}
		            ]
		    }
		    elements << new_element		
		}
		template[:attachment][:payload][:elements] = elements
		post_template(id,template)
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @param template [JSON] The MessageCard to be posted to user's Messager chat.
	# @return [nil]
	# This method helps to post the MessageCards that contains featured articles to user's Messenger chat.
	#
	def self.post_template(id,template)
		message_options = {
		"messaging_type": "RESPONSE",
        "recipient": { "id": "#{id}"},
        "message": "#{template.to_json}"
        }
		res = HTTParty.post(FB_MESSAGE, headers: HEADER, body: message_options.to_json)
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @param date [String] The date for on_this_day content required.
	# @return [nil]
	# This method gets on_this_day contents.
	#
	def self.get_on_this_day_summary(id,date)
		language = get_language(id)
		WikipediaRestClient.set_language(language)
		WikipediaRestClient.get_on_this_day(date)
		begin
			on_this_day_content = WikipediaRestClient.get_on_this_day(date)
			raise 'NilClassException' if on_this_day_content == nil
		rescue  
			WikipediaRestClient.set_language("en")
			on_this_day_content = WikipediaRestClient.get_on_this_day(date)
		end
		on_this_day_content
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @return [nil]
	# This method gets news content summaries from Wikipedia.
	#
	def self.get_news_summary(id)
		language = get_language(id)
		WikipediaRestClient.set_language(language)
		begin
			news = WikipediaRestClient.get_news
			raise 'NilClassException' if news == nil
		rescue  
			WikipediaRestClient.set_language("en")
			news = WikipediaRestClient.get_news
		end
		news
	end

	# @param id [Integer] The receiver's Facebook user ID.
	# @param postback [String] postback payload from Buttons/Menu/MessageCards.
	# @return [nil]
	# This method handles postbacks for GET_SUMMARY button from on_this_day and news contents. It also handles subscribe and unsubscribe payloads.
	#
	def self.handle_get_summary_postbacks(id,postback)

		language = get_language(id)

		if postback.include? "GET_ON_THIS_DAY_SUMMARY"
			date = postback.split("_")[6] # splits the postback payload and get the date from it.
			i = postback.split("_")[5].to_i
			postback = postback.gsub("_#{i}_#{date}","")
			on_this_day_content = get_on_this_day_summary(id,date)
			on_this_day_summary = on_this_day_content[i]["text"]
		end


		if postback.include? "GET_NEWS_SUMMARY"
			date = postback.split("_")[4]
			i = postback.split("_")[3].to_i
			postback = postback.gsub("_#{i}_#{date}","")
			if date == Time.now.strftime("%Y/%m/%d") then
				news_contents = get_news_summary(id)
				news_summary = news_contents[i]["story"]
			else
				news_summary = CANT_LOAD_OLD_NEWS_MESSAGE["#{language}"]
			end
		end


		case postback
		when "GET_ON_THIS_DAY_SUMMARY"
			say(id,on_this_day_summary)
		when "GET_NEWS_SUMMARY"
			say(id,news_summary)
		else
			if postback.include? "UNSUBSCRIBE"
				category = postback.gsub("UNSUBSCRIBE_","")
				SubscriptionClass.new.unsubscribe(id,category)
			elsif postback.include? "SUBSCRIBE"
				category = postback.gsub("SUBSCRIBE_","")
				SubscriptionClass.new.subscribe(id,category)
			else
				say(id, CANT_UNDERSTAND_MESSAGE["#{language}"])
			end	
		end
	end

end