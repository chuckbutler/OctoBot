# Description:
#   Scrapes the channel for URLS and hands them off to the DJ API
#
# Dependencies:
#   None
#
# Configuration:
#   DJ_API_URL -- link to DJ API
#
# Commands:
#  paste any compliant URL from... youtube, soundcloud, mixcloud
#  !play - start playlist
#  !shuffle - Shuffle the playlist
#  !clear - Clear the playlist
#  !seed - Seed the playlist with the entire library (useful when !cleared)
#  !skip - Skip the current song (planned voting later)
#
# Author:
#   lazypower

module.exports = (robot) ->
  # Scrape Controls
  robot.hear /https:\/\/(.*).youtube.com(.*)/i, (msg) ->
    videoid = msg.message.text.split("v=")[1]
    processLink msg, 'youtube', videoid

  robot.hear /spotify:track:(.*)/i, (msg) ->
    processLink msg, 'spotify'
  robot.hear /spotify:album:(.*)/i, (msg) ->
    processLink msg, 'spotify'
  robot.hear /spotify:user:(.*)/i, (msg) ->
    processLink msg, 'spotify'

  robot.hear /(.*).soundcloud.com(.*)/i, (msg) ->
    user = msg.message.text.split('/')[3]
    linkid = msg.message.text.split('/')[4]
    processLink msg, 'soundcloud', linkid, user



  # Player Controls
  robot.hear /^!skip/i, (msg) ->
    playCtl(msg, 'Skipping', 'skip')

  robot.hear /^!play/i, (msg) ->
    playCtl(msg, 'Playing', 'play')

  robot.hear /^!shuffle/i, (msg) ->
    playCtl(msg, 'Shuffling playlist', '/playlist/shuffle')

  robot.hear /^!seed/i, (msg) ->
    playCtl(msg, 'Seeding playlist', '/playlist/seed')

  robot.hear /^!clear/i, (msg) ->
    playCtl(msg, 'Clearing playlist', '/playlist/clear')




playCtl = (msg, reply, ctl) ->
  if not process.env.DJ_API_URL
    msg.send "Error: Theres no DJ API specified. Herp Derp set DJ_API_URL"
    return
  url = "#{ process.env.DJ_API_URL }/player/#{ encodeURIComponent(ctl) }"
  msg.http(url).get() (err, res, body) ->
    msg.send "#{reply}"

processLink = (msg, service, linkid='', user='') ->
  if not process.env.DJ_API_URL
    msg.send "Error: Theres no DJ API specified. Herp Derp set DJ_API_URL"
    return
    # Filter by room
  if(msg.message.room != process.env.DJ_ROOM)
    return

  if(service == "youtube")
    url = "#{ process.env.DJ_API_URL }/fetch/youtube/#{ encodeURIComponent(linkid) }"
  if(service == "spotify")
    url = "#{ process.env.DJ_API_URL }/fetch/spotify/#{ encodeURIComponent(msg.message.text) }"
  if(service == "soundcloud")
    url = "#{ process.env.DJ_API_URL }/fetch/soundcloud/#{ encodeURIComponent(user) }/#{ encodeURIComponent(linkid) }"

  console.log(url)

  msg.http(url).get() (err, res, body) ->
    resp = JSON.parse(body)
    msg.send "Job Queued: #{ resp.JobID }"
