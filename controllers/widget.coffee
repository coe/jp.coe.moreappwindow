###*
@param args.callback コールバック引数二つ クリックイベントとアプリ情報
@require AppStoreClient
###
args = arguments[0] || {}

#apple store api 実施
API = "http://itunes.apple.com/search?"
IOS_URL = "http://itunes.apple.com/search?term=tsuyoshi+hyuga&country=#{Ti.Locale.getCurrentCountry()}&media=software&entity=software"
ANDROID_URL = "http://play.google.com/store/search?q=tsuyoshi+hyuga"
#ANDROID_YQL="SELECT content FROM data.headers WHERE url='#{ANDROID_URL}' and ua='Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 5.1)'"
ANDROID_YQL="select * from html where url=\"#{IOS_URL}\""
URL=API#"http://coecorsproxy.appspot.com/"

_callback = args.callback

###*
クリック時のコールバック設定
###
exports.setClickCallback = (callback)->
  _callback = callback

callbackfunc = (e)->
  console.debug "callbackfunc to " + e


###*
ローディングビュー出す
###
setLoadingView = (torf)->
  $.loading_view.visible = torf
  if torf
    $.loading.setOpacity(1.0)
  else
    $.loading.setOpacity(0.0)

fetchAndroidInfo = ->
  #yql="select * from html where url=\"#{urlobj.url}\" and xpath=\"\/\/link[@rel='audio_src']\""
  #Ti.App.Const.warn? "yql:#{yql}"
  unless ENV_PRODUCTION then Ti.API.debug "yql:#{ANDROID_YQL}"
  Ti.Yahoo.yql ANDROID_YQL,(e)=>
    #unless ENV_PRODUCTION then Ti.API.debug e.data.body.p
    json = JSON.parse e.data.body.p
    unless ENV_PRODUCTION then Ti.API.debug JSON.stringify json #JSON.stringify e

fetchIOSInfo = ->
  #yql="select * from html where url=\"#{urlobj.url}\" and xpath=\"\/\/link[@rel='audio_src']\""
  #Ti.App.Const.warn? "yql:#{yql}"
  unless ENV_PRODUCTION then Ti.API.debug "yql:#{ANDROID_YQL}"
  Ti.Yahoo.yql ANDROID_YQL,(e)=>
    #unless ENV_PRODUCTION then Ti.API.debug e.data.body.p
    json = JSON.parse e.data.body.p
    unless ENV_PRODUCTION then Ti.API.debug JSON.stringify json #JSON.stringify e

clickRowCallback = (e,appdata)->
  Ti.API.debug "ここここ"
  # Ti.API.debug "callback #{JSON.stringify appdata}"
  #クリックはコールバックに返す
  _callback e,appdata


  
getItunesData = (e)->
        #json化
        unless ENV_PRODUCTION then Ti.API.debug "getItunesData"
        json = JSON.parse @responseText
        data = json.results
        #TODO データのうち、無料のものを抽出 underscoreで
        data = _.filter data,(obj)->
          obj.price is 0
        unless ENV_PRODUCTION then Ti.API.debug "1:#{JSON.stringify data}"
        #TODO データを、アップデート日付順にソート underscoreで
        data = _.sortBy(data, (item) ->
          Number(item.releaseDate)
        )
        unless ENV_PRODUCTION then Ti.API.debug "2:#{JSON.stringify data}"
        #TODO 自分のアプリIDは除外 bundleId
        data = _.filter data,(obj)->
          obj.bundleId isnt Ti.App.id
        unless ENV_PRODUCTION then Ti.API.debug "3:#{JSON.stringify data}"
        
getItunesDataNew = (data)->
  data = _.filter data,(obj)->
    obj.price is 0

  rows = for name in data
    name.clickRowCallback = clickRowCallback
    Widget.createController("AppRow",name).getView()
  $.table.data = rows
  setLoadingView no
  $.label?.text = "end"

refresh = ->
  AppStoreClient = require "AppStoreClient/AppStoreClient"
  #asc = new AppStoreClient()
  AppStoreClient.getItunesData (datas)->
    getItunesDataNew datas
    $.loading.setOpacity(0.0)
    setLoadingView no
  ,(e)->
    setLoadingView no
  
refreshold = ->

  # unless OS_IOS
    # fetchIOSInfo()
  # else if OS_IOS

    
    unless ENV_PRODUCTION then Ti.API.debug "ああああ"
    setLoadingView yes
    $.label?.text = "loading"
    $.table.data = []
    url = IOS_URL#"https://itunes.apple.com/search?term=tsuyoshi+hyuga&country=#{Ti.Locale.getCurrentCountry()}&media=software&entity=software"
    unless ENV_PRODUCTION then Ti.API.debug url
    client = Ti.Network.createHTTPClient(
      
      # function called when the response data is available
      onload: getItunesData #(e) ->
        # unless ENV_PRODUCTION then Ti.API.debug @responseText
        # getItunesData 
      onerror: (e) ->
        #Ti.API.error url+" "+JSON.stringify e
        setLoadingView no
        $.label?.text = "error"
      timeout: 5000 # in milliseconds
    )
    
    # Prepare the connection.
    client.open "GET", url
    # Send the request.
    client.send()

clickMore = ->
  Ti.Platform.openURL "market://search?q=tsuyoshi+hyuga"

windowFocus = ->
  refresh()

do ->
  refresh()