require 'Uri'

# Dropzone Action Info
# Name: stikked
# Description: Sends the dropped text to stikked (s.m1rad.de) and puts the resulting URL on the pasteboard.
# Handles: Text, Files
# Creator: Alexander Schramm
# URL: http://yoursite.com
# Events: Clicked, Dragged
# SkipConfig: Yes
# RunsSandboxed: Yes
# Version: 1.0
# MinDropzoneVersion: 3.0

$apikey="Your api Key if needed"
$stikked_url = "Your stikked Url"
$name = "Your name"

$short_link = true #wether to use yourls to shorten the link
$yourls_url="Path of your yourls isntallation"
$signature="your yourls signature"

def dragged
  case ENV['dragged_type']
    when 'files'
      $items.each do |file|
        data = File.read(file)
        paste(File.basename(file, '.*'), data)
      end
    when 'text'
      # TODO
      true
  end
end

def paste(title = 'unknown', data)
  $dz.determinate(false)
  $dz.begin("Performing Paste...")

  stikked_create_path = "#{$stikked_url}api/create"
  if $apikey
    stikked_create_path += "?apikey=#{$apikey}"    
  end
  #Todo: figure out language 

  response = HTTParty.post(stikked_create_path, body: {text: data, title: title,name: $name}, verify: false)
  url = response.body
  
  if $short_link
    response = HTTParty.get("#{$yourls_url}?signature=#{$signature}&action=shorturl&url=#{url}", verify: false)
    url = response["result"]["shorturl"]    
  end
  
  $dz.finish("URL is now on clipboard")
  $dz.url(url)
end

def clicked
  system("open #{$stikked_url}")
end
