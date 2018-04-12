---
destination: /blog
---

<!DOCTYPE HTML>
<html lang="en-US">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="refresh" content="0; url={{ page.destination }}">
        <script type="text/javascript">
            window.location.href = "{{ page.destination }}"
        </script>
        <title>Page Redirection</title>
    </head>
    <body>
        <!-- Note: don't tell people to `click` the link, just tell them that it is a link. -->
        If you are not redirected automatically, follow this <a href='{{ page.destination }}'>link to example</a>.
    </body>
</html>