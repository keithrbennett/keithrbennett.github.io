---
id: 584
title: "Conway's Game of Life Viewer"
date: 2012-09-05T23:30:57+00:00
author: keithrbennett
guid: http://www.bbs-software.com/blog/?p=584
permalink: /index.php/2012/09/05/conways-game-of-life-viewer/
categories:
  - Uncategorized
---
Later this month I&#8217;ll be joining dozens of other coders at [Ruby DCamp](http://rubydcamp.org/), where we&#8217;ll spend three days talking, coding, and camping. The first day is usually code katas (exercises), and often one of them is the implementation of [Conway&#8217;s Game of Life](http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

By design, there&#8217;s not enough time to do a complete implementation with viewer, so I thought it would be cool to write a viewer into which you could plug your own model implementation and &#8220;play&#8221; that model visually.

In addition to using the viewer to run different implementations of the Game of Life, it could also be useful in coming up with illustrative and interesting game data, using the provided model implementation.

We often have poor or nonexistent Internet connectivity, and client/server seemed to be overkill, so I brushed off my old Java Swing skills and wrote a minimal viewer in JRuby. The code is at [https://github.com/keithrbennett/life\_game\_viewer](https://github.com/keithrbennett/life_game_viewer).

Here&#8217;s a screen shot:

![screenshot]({{ site.url }}/assets/life-game-viewer7.png)


  In case you don&#8217;t recognize the face, it&#8217;s Alfred E. Neuman, made famous by Mad magazine, but, as I just learned this minute from Wikipedia (I read it there so it <em>must</em> be true), &#8220;[his] face had drifted through American pictography for decades before being claimed and named by <em>Mad</em>&#8230;&#8221;&#8230;but I digress&#8230;

You can install the gem in the usual way (make sure you&#8217;re in JRuby when you do):

```
>gem install life_game_viewer
```

A sample model implementation with sample initial values are provided so that you can play with the viewer before beginning the exercise. This sample implementation is available by running `LifeGameViewer::Main.view_sample` in irb, or `life_view_sample` on the command line.

You can&#8217;t see it in this image, but if you hover over a cell, a tool tip containing the coordinates and the value (alive or not) will be displayed.

One of my favorite features is the simplicity of data initialization. One of the required model methods is a static method _create_, which takes a row count, column count, and optionally, a block with which to initialize each cell. This makes it simpler and more concise to experiment with forumulas and patterns. For example, the code below would result in an X shaped board, and is all the code you&#8217;d need to run the viewer.

```ruby
require 'life_game_viewer'

model = SampleLifeModel.create(12, 12) do |row, col|
  (row + col == 11) || (row == col)
end
LifeGameViewer::Main.view(model)
```

<figure id="attachment_688" class="thumbnail wp-caption aligncenter" style="width: 810px">

[<img src="http://www.bbs-software.com/blog/wp-content/uploads/2012/09/life-game-viewer-x-board1.png" alt="Board initialized with: (row + col == 11) || (row == col)" title="life-game-viewer-x-board" width="800" height="565" class="size-full wp-image-688" />](http://www.bbs-software.com/blog/wp-content/uploads/2012/09/life-game-viewer-x-board1.png)<figcaption class="caption wp-caption-text">Board initialized with: (row + col == 11) || (row == col)</figcaption></figure> 

There&#8217;s a lot more information, including instructions and troubleshooting, on the [Life Game Viewer project page](https://github.com/keithrbennett/life_game_viewer), and in comments in the source code.