Fonts
=====

The source code repository of malayalam unicode fonts developed or maintained by SMC.

* Anjali Old Lipi
* Dyuthi
* Kalyani
* Meera
* Rachana
* Raghu Malayalam Sans
* Suruma

How to Build
=====

To generate TTF Files, run,
    $ ./generate.pe folder/file.sfd

To test,
    $ hb-view folder/file.ttf --text-file tests/tests.txt --output-file test.png
