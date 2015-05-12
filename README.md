# Snipp.IO

This is a pastebin application made out of Yesod and mongodb, by Charlie Harvey. Yes, it does sound a bit fucking hipster. What can I say? At least it’s not ruby.

The idea is that you can log in with your openid (or Google or Yahoo! account if you must) and paste stuff straight to the web.

### On the interwebs

Just go to (https://snipp.io)[snipp.io], log in with whatever thingummy and paste stuff.

### From the commandline

It is entirely possible to use Snipp.IO from the commandline, which is my primary use case. Perhaps it will be useful for you as well.

To POST your snippets from the commandline, you’ll need an API key. Log in and it’s at the bottom of each page, in the footer.

Here’s an example of using Snipp.IO from the commandline with curl.

$ echo hello snippio |
curl -L -d t='my snip'
-d k=[apikey]
--data-urlencode c@- http://snipp.io/s

This will return an URL that you can visit in your browser.

### Caveat emptor

I’d love to have unlimited storage, but I don’t. I have a free 512MB sandbox account courtesy of MongoHQ (thanks!). So stuff may vanish.

