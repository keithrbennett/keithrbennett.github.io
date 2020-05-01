---
title: Adding Bootstrap to Your Rails 6 Application
published: true
---

### Introduction

In this article I will discuss a very simple approach to configuring your Rails 6 application to work with [Bootstrap](https://getbootstrap.com/). An [entire Rails repo](https://github.com/keithrbennett/rails-bootstrap-example) is provided, including commit history, but you may only need a single patch file from it.

I recently wanted to add [Bootstrap](https://getbootstrap.com/) to a new Rails 6 application, but even after reading the [documentation](https://getbootstrap.com/docs/4.4/getting-started/introduction/) and several blog articles, success eluded me.

What finally worked was to follow along with [this article](https://gorails.com/episodes/how-to-use-bootstrap-with-webpack-and-railsarticle) by [Chris Oliver](https://twitter.com/excid3) -- well, more precicely, the [_video_](https://www.youtube.com/watch?v=bn9arlhfaXc) linked to in the article.
In it, he shows exactly what to do -- and doing what he said to do worked for me.

### Even Simpler -- A Patch

In order to even further simplify the process for future developers, I generated a [patch file](https://github.com/keithrbennett/rails-bootstrap-example/blob/master/0001-Apply-patch-for-Bootstrap.patch) to make the changes needed to provide the correct configuration. (They do assume a new Rails application, so it's possible that some modification to the changes would be required for existing projects.)

Here's how to do it.

I suggest you have a "clean working tree" (no git-relevant changes since the previous commit) before you apply the patch; this will make it easier to revert the change or limit your next commit to only Bootstrap configuration.

Change directory to your project root.

You can download the patch in its [raw format](https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0001-Apply-patch-for-Bootstrap.patch) to your local filesystem with the following command:

```
curl -o bootstrap.patch https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0001-Apply-patch-for-Bootstrap.patch
```

Then apply the patch:

```
git apply bootstrap.patch
```


Alternatively, you can combine the above two steps into one:

```
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0001-Apply-patch-for-Bootstrap.patch | git apply -
```


You can see the changes with a `git diff`.

### Adding the JavaScript Libraries

At some point (either before or after the patch) you will need to add the necessary JavaScript libraries:

```
yarn add bootstrap jquery popper.js
```

### Testing that Bootstrap Works

We'll want to exercise Bootstrap to verify that it is working correctly. 

The `index.html.erb` [file in the repo]((https://github.com/keithrbennett/rails-bootstrap-example/blob/master/app/views/home/index.html.erb)) uses Bootstrap colored border spinners requiring both CSS and JavaScript provided by Bootstrap, and is a good test. Of course, you can find many other components to use in the Bootstrap [docs](https://getbootstrap.com/docs/4.4/getting-started/introduction/).

The rest of this section discusses setting up a sample app using the patches provided. Here is a list of all the patches, including the one we already applied:

``` 
0001-Apply-patch-for-Bootstrap.patch                             # already used, to configure Bootstrap
0002-yarn-add-bootstrap-jquery-popper.js.patch                   # only if `yarn add` not run
0003-rails-g-controller-home-index.patch                         # this and the next 2 (3-5) can be used...
0004-Change-root-route-to-go-to-new-home-index.patch             # ...to put something in the home page to... 
0005-Add-Bootstrap-color-border-spinners-to-home-page-to-.patch  # ...test that Bootstrap is working.
 ```
 
These patches are in the [project root](https://github.com/keithrbennett/rails-bootstrap-example).

Applying patches #3 through #5 will set up the sample code to show that Bootstrap is working. Here are commands that will apply the patches directly from Github (without creating patch files on your system):

```
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0003-rails-g-controller-home-index.patch | git apply -
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0004-Change-root-route-to-go-to-new-home-index.patch | git apply -
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0005-Add-Bootstrap-color-border-spinners-to-home-page-to-.patch | git apply -
```

This is all you should need to do! At this point you can run `rails s` and connect to it in your browser. If all goes well you will see something like this:

![successful Bootstrap page](/assets/success-page.png)



