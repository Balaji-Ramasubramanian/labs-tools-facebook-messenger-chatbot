require 'wikipedia_rest_client'

class MessengerBot
	
	def self.get_random(id)
		random_page = WikipediaRestClient.get_random
		post_page(id,random_page,true)
	end

	def self.get_page(id,query)
		page = WikipediaRestClient.get_page(query)
		if page.pageid != nil then
			post_page(id,page)
		else
			say(id,"\"#{query}\" - #{PAGE_NOT_FOUND_MESSAGE["#{@language}"]} ")
		end
	end

	def self.post_page(id,page,is_random = false)
		begin
			title = page.title
			text = page.text
			url = page.url
			thumbnail_url = page.thumbnail_source if page.thumbnail_source
			thumbnail_url = WIKIPEDIA_LOGO unless page.thumbnail_source
			template = GENERIC_TEMPLATE_BODY
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
	              		"title": READ_MORE_BUTTON["#{@language}"],
	              		"url": url
	            	}
	        	]      
	        }]
	        post_template(id,template)
	    rescue  
	    	if is_random then
				WikipediaRestClient.set_language("en")
				get_random(id)
			else
				say(id,PAGE_NOT_FOUND_MESSAGE["#{@language}"])
			end
		end
	end
end