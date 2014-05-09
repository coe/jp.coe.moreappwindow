###*
@param APP itunesのデータ+コールバック
###
APP = arguments[0] || {}
data = []

$.appicon.image = APP.artworkUrl60
$.apptitle.text = APP.trackName
$.price.text = "無料"

clickRow = (e)->
  APP.clickRowCallback e,APP
  