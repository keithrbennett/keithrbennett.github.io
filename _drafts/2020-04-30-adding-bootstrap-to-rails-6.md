---
title: Adding Bootstrap to Your Rails 6 Application
published: true
---

### Introduction

In this article I will discuss a very simple approach to configuring your Rails 6 application to work with
[Bootstrap](https://getbootstrap.com/). An [entire Rails repo](https://github.com/keithrbennett/rails-bootstrap-example)
is provided, including commit history, but this might be all you need:

```
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0001-Add-Bootstrap-configuration.patch | git apply -
yarn add bootstrap jquery popper.js
```

I recently wanted to add Bootstrap to a new Rails 6 application,
but even after reading the [documentation](https://getbootstrap.com/docs/4.4/getting-started/introduction/)
and several blog articles, success eluded me.

What finally worked was to follow along with 
[this article](https://gorails.com/episodes/how-to-use-bootstrap-with-webpack-and-rails)
by [Chris Oliver](https://twitter.com/excid3) -- well, more precicely,
the [_video_](https://www.youtube.com/watch?v=bn9arlhfaXc) linked to in the article.
In it, he shows exactly what to do -- and doing what he said to do worked for me.

### Even Simpler -- A Patch

In order to even further simplify the process for future developers, I generated a 
[patch file](https://github.com/keithrbennett/rails-bootstrap-example/blob/master/0001-Add-Bootstrap-configuration.patch)
to make the changes needed to provide the correct configuration. (These changes do assume a new Rails application,
so it's possible that some modification to the changes would be required for existing projects.)

Here's how to do it. You can make the changes to your existing project or a fresh one generated with `rails new`.

Change directory to your project root.

I suggest you have a "clean working tree" (no git-relevant changes since the previous commit)
before you apply the patch; this will make it easier to revert the change or limit your next commit
to only Bootstrap configuration.

You can download the patch in its 
[raw format](https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0001-Add-Bootstrap-configuration.patch)
to your local filesystem with the following command:

```
curl -o bootstrap.patch https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0001-Add-Bootstrap-configuration.patch
```

Then apply the patch:

```
git apply bootstrap.patch
```


Alternatively, you can combine the above two steps into one:

```
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0001-Add-Bootstrap-configuration.patch | git apply -
```


You can see the changes with a `git diff`.

### Adding the JavaScript Libraries

At some point (either before or after the patch) you will need to add the necessary JavaScript libraries:

```
yarn add bootstrap jquery popper.js
```

This will make changes to `package.json` and `yarn.lock` that will need to be committed.

### Testing that Bootstrap Works

We'll want to exercise Bootstrap to verify that it is working correctly. 

The `index.html.erb` 
[file in the repo](https://github.com/keithrbennett/rails-bootstrap-example/blob/master/app/views/home/index.html.erb)
uses Bootstrap colored border spinners requiring both CSS and JavaScript provided by Bootstrap, and is a good test.
Of course, you can find many other components to use in the Bootstrap
[docs](https://getbootstrap.com/docs/4.4/getting-started/introduction/).

The rest of this section discusses setting up a sample app using the patches provided.
Here is a list of all the patches:

``` 
# already used above, to configure Bootstrap
0001-Add-Bootstrap-configuration.patch                       

# These next 3 can be used to put something in the
# home page to test that Bootstrap is working:
0002-rails-g-controller-home-index.patch
0003-Change-root-route-to-go-to-new-page.patch
0004-Add-Bootstrap-color-border-spinners-to-page.patch
```
 
These patches are in the [project root of the sample repo](https://github.com/keithrbennett/rails-bootstrap-example).

Applying patches #2 through #4 will set up the sample code to show that Bootstrap is working. 
Here are commands that will apply the patches directly from Github (without creating patch files on your system):

```
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0002-rails-g-controller-home-index.patch | git apply -
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0003-Change-root-route-to-go-to-new-page.patch | git apply -
curl https://raw.githubusercontent.com/keithrbennett/rails-bootstrap-example/master/0004-Add-Bootstrap-color-border-spinners-to-page.patch | git apply -
```

This is all you should need to do! At this point you can run `rails s` and connect to it in your browser. 
If all goes well you will see something like this:

![successful Bootstrap page](/assets/success-page.png)

### Git's Patch Support

You may have noticed that the patch file names were numbered and contained the first part of the commit messages
in the names. This was not something I did myself, this was done automatically by git. Git has great patch support,
and all I needed to do to generate the patches was issue this command:

```
$ git format-patch HEAD~4
0001-rails-g-controller-home-index.patch
0002-Change-root-route-to-go-to-new-page.patch
0003-Add-Bootstrap-color-border-spinners-to-page.patch
0004-Add-patch-files-git-format-patch-HEAD-4.patch
```

The `HEAD~4` told git how far back I wanted to start (4 commits).

As you saw above, applying a patch to a code base is as simple as:

```
git apply something.patch
```

----

### Conclusion

I hope that the hours I invested in creating and documenting this simplifying procedure will pay off
in the form of time saved for you. If you think I could be useful on your project, or would just like
to say hello, please give me a holler at [kbennett@bbs-software.com](mailto:kbennett@bbs-software.com).
