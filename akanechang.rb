#!/usr/bin/env ruby

require "net/http"
require "uri"
require "json"
require "sanitize"
require "sinatra"

TOOT_LIST = "https://raw.githubusercontent.com/Akane-Blue/gallery/master/list.txt"

get "/" do
  TOOT_URL  = Net::HTTP.get( URI.parse(TOOT_LIST) ).split(" ").sample
  #TOOT_URL  = "https://pawoo.net/@pacochi/62284170"
  #TOOT_URL  = "https://pawoo.net/@pacochi/100328915736955380"
  TOOT_HOST, TOOT_ID  = URI.parse(TOOT_URL).host, URI.parse(TOOT_URL).path.split("/").last
  TOOT_JSON = Net::HTTP.get( URI.parse("https://#{TOOT_HOST}/api/v1/statuses/#{TOOT_ID}") )
  TOOT_PARSED = JSON.parse(TOOT_JSON)

  # header
  body =<<EOF
<!DOCTYPE html>
  <html lang="ja">
    <head>
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <title>Akanechang !</title>
      <meta charset="utf-8">
      <meta name="description" content="ｱｶﾈﾁｬﾝｶﾜｲｲﾔｯﾀｰ">
      <meta name="author" content="@owatan@mstdn.maud.io">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <!--[if lt IE 9]>
        <script src="//cdn.jsdelivr.net/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="//cdnjs.cloudflare.com/ajax/libs/respond.js/1.4.2/respond.min.js"></script>
      <![endif]-->
    </head>
    <body>
EOF

  JSON.parse(TOOT_JSON)["media_attachments"].each do |img|
    if img["type"] == "gifv"
      body += "<video controls autoplay name='media'>"
      body += "<source src='#{img["text_url"]}' type='video/mp4'>"
      body += "</video>"
    else
      body += "<img src='#{img["text_url"]}' alt='#{img["text_url"]}' style='max-width: 100%' />"
    end
  end

  body += "<p>#{Sanitize.fragment(JSON.parse(TOOT_JSON)["content"])}</p>"

  # footer
  body += "<hr />"
  body += "<p>#{TOOT_PARSED["account"]["display_name"]} - @#{TOOT_PARSED["account"]["username"]} <br />"
  body += "<a href='#{TOOT_URL}'>#{TOOT_URL}</a></p>"
  body += "</body>"
  body += "</html>"

  body
end
