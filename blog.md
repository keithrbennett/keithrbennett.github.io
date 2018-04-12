---
# You don't need to edit this file, it's empty on purpose.
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---

<script>
// Don't force https when serving the website locally
if (!(window.location.host.startsWith("127.0.0.1")) 
    && !(window.location.host.startsWith("localhost")) 
    && (window.location.protocol != "https:"))
    && !(window.location.contains("www"))
    
    window.location.protocol = "https";
</script>
