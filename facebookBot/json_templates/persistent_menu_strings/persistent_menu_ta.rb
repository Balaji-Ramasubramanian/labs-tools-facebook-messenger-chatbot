require_relative '../../strings'

class MessengerBot

PERSISTENT_MENU_STRING_TA =
      {
        "locale": "ta_IN",
         "composer_input_disabled": false,
        "call_to_actions": [
           {
            "title": RANDOM_ARTICLE_MESSAGE["ta"],
            "type": "postback",
            "payload": "RANDOM_ARTICLE"
          },
          {
            "title": FEATURED["ta"] ,
            "type": "nested",
            "call_to_actions": [
              {
                "title": FEATURED_ARTICLE_MESSAGE["ta"],
                "type": "postback",
                "payload": "FEATURED_ARTICLE"
              },
              {
                "title": IMAGE_OF_THE_DAY_MESSAGE["ta"],
                "type": "postback",
                "payload": "IMAGE_OF_THE_DAY"
              },
              {
                "title": MOST_READ_MESSAGE["ta"],
                "type": "postback",
                "payload": "MOST_READ"
              },
              {
                "title": ON_THIS_DAY_MESSAGE["ta"],
                "type": "postback",
                "payload": "ON_THIS_DAY"
              }

            ]
          },
          {
            "title": MORE_BUTTON["ta"],
            "type": "nested",
            "call_to_actions": [
              {
                "title": SUBSCRIPTION_BUTTON["ta"],
                "type": "postback",
                "payload": "SUBSCRIPTION"
              },
              {
                "title": LANGUAGE_SETTINGS_BUTTON["ta"],
                "type": "postback",
                "payload": "LANGUAGE_SETTINGS"
              },
              {
                "title": HELP_BUTTON["ta"],
                "type": "postback",
                "payload": "HELP"
              }
            ]
          }
        ]
      }

end