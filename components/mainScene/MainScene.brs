function init() as Void
  m.hardcodedImageUrls = ["pkg://images/fullscreen_earth.jpg", "pkg://images/fullscreen_moon.jpg"]
  m.backgroundPoster = m.top.findNode("backgroundPoster")

  m.menuHolder = m.top.findNode("menuHolder")
  m.mainMenu = m.menuHolder.createChild("mainMenu")
  m.mainMenu.observeField("itemFocused", "menuItemFocused")
  m.mainMenu.setFocus(true)
end function

function menuItemFocused() as Void
   m.backgroundPoster.uri = m.hardcodedImageUrls[m.mainMenu.itemFocused]
end function
