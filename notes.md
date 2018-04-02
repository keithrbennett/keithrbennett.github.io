See instructions at https://github.com/benbalter/jekyll-remote-theme for 
how to use a remote theme.

Cannot get any theme other than the default to work. Reverted to minima theme.

Added:

plugins:
  - jekyll-feed
  - jekyll-remote-theme    <--
  
Didn't work:

#remote_theme: benbalter/retlab
#remote_theme: fongandrew/hydeout
#theme: retlab
  
Used the WordPress plugin "WordPress to Jekyll Exporter" for converting a WordPress blog to Jekyll.
All posts had front matter that included:

layout: post

But all the themes I've tested other than the default `minima` theme apparently
do not have this layout, because I get error messages like this from the Jekyll server
for every post:

`Build Warning: Layout 'post' requested in _posts/2015-11-07-the-case-for-nested-methods-in-ruby.md does not exist.`

What's happening here? Are all the themes intended for web sites that are not blogs?

Is there a simple fix for this?

My higher level goal is to experiment with themes other than minima to find something a bit more
ornate than the default `minima` theme.

