#Working with components

Compared to SDK1 working with SceneGraph components is super easy. SceneGraph itself has a display hierarchy that is handled natively. Meaning that items at the lowest in the z-order are drawn first and items higher up in the z-order are drawn last (as you’d expect). It is based on a tree structure where each node is a renderable or non renderable component.

If you've done any work with custom Roku apps you know the pain that comes with drawing to the screen or working with compositors. Basically, plenty of bugs. To get round this the best way I've found is to write your own framework with its own display hierarchy and rendering functionality. *Now the scene graph handles all of this for you.*

If you add a component to a component - that component becomes a child component of the original component, and the child component will be drawn to screen after the parent. This also means that certain properties of the parent nodes are inherited by the child nodes. A good example of this would be X,Y coordinates. If you translate a parents node X,Y coordinates it'll be passed down the tree and inherited by the child nodes. Same goes for transparency and scale.

Scene Graph also includes easy handling for RCU events - these are now handled directly within components (just add `onKeyEvent` code) and is propagated/bubbled up through the display hierarchy. This is loads easier than before where you'd either have to pass the event from the event loop directly to your component or react to the RCU input dependant on what state the app is in.

##XML configuration of screens

As mentioned yesterday you are now able to create screens and UI components as XML. XML lends itself nicely to a tree structure using nested XML nodes.

So the components - you can either create your own - which are basically a group of Scene Graph Nodes and also Roku have introduced some ready made ones to help build custom apps. An example of these are:

 - Poster - an image component - finally
 - Label - for use with drawing text
 - Video
 - Pin pad
 - Keyboard
 - Panels
 - Buttons
 - Input boxes
 - Truncating text
 - Mask group

##Adding components to the display hierarchy

So with all this information in mind lets start putting together a simple UI. We are going to create a UI with a menu that switches a fullscreen image when you cycle through the options.

You can add components directly to the XML. Below we add a Poster component to a Scene.

```
<?xml version="1.0" encoding="utf-8" ?>

<component name="MainScene" extends="Scene" >
    <interface>
    </interface>

    <children>

      <Poster
      id="backgroundPoster"
      uri="pkg://images/fullscreen_earth.jpg"
      width="1280"
      height="720"
      translation="[0,0]" />

      <Group id="menuHolder" />

    </children>
    <script type="text/brightscript" uri="pkg://components/mainScene/MainScene.brs" />
</component>

```

If you ran this you would get a lovely image drawn to the screen (as long as `pkg://images/fullscreen_earth.jpg`, which in our example, we do).

Nesting components between the `children` nodes in the XML is one way you can add components. But you can also add components through Brightscript.

In our `MainScene.brs` let’s add a menu component - this menu component is going to be a custom component (discussed further below).

```
function init() as Void
  m.menuHolder = m.top.findNode("menuHolder")
  m.mainMenu = m.menuHolder.createChild("mainMenu")
end function

```

`m.top` is a special case within SceneGraph nodes as it references the topmost node for the SceneGraph XML component. You will see it used often. Here we use the `findNode` method to locate the `Group` we named `menuHolder` in the XML. We then add a child of type `mainMenu` to the menuHolder `Group` node.

##Creating a custom component
Above we referenced `mainMenu`. This isn’t a fully native SceneGraph component set but is a custom(ish) component (it's as simple as custom components get - just extending a native component).

```
<?xml version="1.0" encoding="utf-8" ?>

<component name="MainMenu" extends="LabelList" >

  <children>

    <ContentNode id="mainMenuContent" role="content" >

      <ContentNode title="Earth" />
      <ContentNode title=“Moon” />

    </ContentNode>

  </children>

</component>
```

You components can be groups of other components but this component just extends the SceneGraph component `LabelList` (Info on `LabelList` can be found [here](https://sdkdocs.roku.com/display/sdkdoc/LabelList).

As you can see we have added two `ContentNodes` to the children. We add `ContentNode’s` to add data to our components. If you look at the first `ContentNode` you can see we have given it an attribute named `role` and it’s value is `content`. This makes sure that these elements get rendered as the data for the component. If you ran the app now you would get a nice background image but nothing would happen if we use the RCU.

##Focusing components
SceneGraph makes handling focus a lot easier than using SDK1. For our example it’s as easy as adding `m.mainMenu.setFocus(true)` to your `init` method of your `MainScene.brs`. It get’s slightly more complex with more complex UI but that’s about it.

```
function init() as Void
  m.menuHolder = m.top.findNode("menuHolder")
  m.mainMenu = m.menuHolder.createChild("mainMenu")
  m.mainMenu.setFocus(true)
end function
```

##Observers
SceneGraph introduces native observable interfaces. If a component has a property that is made available via it’s interface you are able to watch that property, and when it changes trigger a function call. We are going to use this to change our background image.

To observe a property first find the one you’re after in the [SDK docs](https://sdkdocs.roku.com/display/sdkdoc/LabelList). I’m going to go with `itemFocused` so it triggers when we click up or down on the menu. To observe the field we add the line `m.mainMenu.observeField("itemFocused", "menuItemFocused”)` seen below. We also have to add the `menuItemFocused` function to handle when the event is triggered. Below we are just tracing out the value of the focused item in the menu.

```
function init() as Void
  m.menuHolder = m.top.findNode("menuHolder")
  m.mainMenu = m.menuHolder.createChild("mainMenu")
  m.mainMenu.observeField("itemFocused", "menuItemFocused")
  m.mainMenu.setFocus(true)
end function

function menuItemFocused() as Void
   ? m.mainMenu.itemFocused
end function
```

Now we need to do something useful with that observed event - we are going to change the image. Awesome! To do this I’m just going to hardcode the urls of the images into an array I can use to reflect the focused item of the menu.

```
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
```

Above all we are doing is setting the `uri` property of the `Poster` to one of the hardcoded images and it updates. Imagine doing that with SDK1!?

##Challenges

Here are some challenges to get through - your friend for this kind of thing are the [sdk docs](https://sdkdocs.roku.com/display/sdkdoc/Roku+SDK+Documentation) :)
 - Make it so the image changes when you click on the menu rather than when you change the menu
 - Add a multi line text label via XML that changes its placeholder text when you click a menu item
 - Use an animation node to make the current background image fade out and then back in with the new image
 - Create some nested images on top of the screen using brightscript rather than xml
