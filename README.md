CoronaDropbox1
==============

Sample code for REST acceess to Dropbox from Corona SDK

This sample code is a modified version of the Corona SDK sample code for accessing Twitter via REST.  In order to make it work, you need to register with Dropbox as a developer and you need to set up an "app" and get the key token and the secret token.  You can then paste those into the appropriate place in the DropBox.lua file.  I also changed the signature method from HMAC-SHA1 to PLAINTEXT in oAuth.lua.  My understanding at the time was that was necessary for Dropbox.  That may or may not currently be true.  Also, since I changed the signature method, I commented out the code necessary for the hmac encoding and you can see that in oAuth.lua.

All this sample app really does is allow you to open Dropbox in a Corona webpopup.  I have not added any Dropbox command functionality.  Hopefully it helps get you started.

Enjoy!  and please let me know if you come up with enhancements.
