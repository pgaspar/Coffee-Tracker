Coffee Tracker
==============

A quick and dirty Sinatra app for tracking coffee consumption.

We're using it at [Connect Coimbra](http://connectcoimbra.com/ "Connect Coimbra") with about 10 people.

![Screenshot](http://dl.dropbox.com/u/562461/hot-linking/coffee_tracker_github.png "Front Page screen")

Features
--------

* Users managed by the administrator
* Each coffee drink is stored with a timestamp, the type of coffee and the price at time of consumption
* Overall stats displayed on the main page
* Easily filter by month (not in the interface at the moment)
* Extremely simple interface / idea

Issues
------

The first version was stitched up in about 4 hours with KISS in mind, so there's a lot of room for improvement!

### Main issues ###

* The login is cookie based but requires no password (the user selects himself from the list of users) - this doesn't scale and has privacy issues
* The views are tightly coupled with our needs and are generally awful
* Hardcoded coffee types and prices
* Site's copy currently in Portuguese

Powered by
----------

* [Sinatra](http://sinatrarb.com/ "Sinatra")
* [Data Mapper](http://datamapper.org/ "Data Mapper")
* [Twitter Bootstrap](http://twitter.github.com/bootstrap "Twitter Bootstrap")
* The nice people at [Connect Coimbra](http://connectcoimbra.com/ "Connect Coimbra") :)