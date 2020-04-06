# Super Portal

## Overview

You're building your own real estate portal (it's always been your dream) but you unfortunately don't have any properties to put on your fancy new website. You luckily strike a deal with EasyBroker where they offer you an XML feed of all their properties. In production these files contain more than 100,000 properties!

You can download an example XML file with documentation in [doc/sample-easybroker-feed_1_01.xml](doc/sample-easybroker-feed_1_01.xml) and you can access a live one which is updated at 10:00am, 6:00pm and 2:00am on our staging server at [easybroker_MX.xml.gz](http://www.stagingeb.com/feeds/dc3122988c6d81d750eba0825adba94d049f0559/easybroker_MX.xml.gz). Your job is to synchronize the staging file with your local database.

## Requirements

### Database and Models

For the purpose of this project you must use the provided sqlite database even though it's not made for production. There are a base set of models to get you started and you should respect their validations. You should use the existing models but you'll need to at least add the following

* External ID (Maps to the EasyBroker ID in feed. It should be a string since you can't enforce the format)
* Neighborhood (Required. Every property in the feed should have one. Ignore properties without neighborhoods)
* Property Images (Order is important)
* Features (Each feature is a string that won't change. The full list is in the sample XML file)

Keep in mind that in the future you will want to add filters to your website for the fields above. For example you might want search all rental properties in Condesa that have a pool. You can ignore any extra fields that are in the XML feed and not listed above or not already included in the schema. You can also ignore temporary rentals and prices in units such as $75 per m2. If you encounter a price with units you should leave the price blank and set the operation type.

### Synchronizer

Implement the [EasyBrokerSynchronizer](app/synchronizers/easy_broker_synchronizer.rb) class. You aren't limited to creating just one class but this should be where you initiate the synchronizing code which you can call via the provided task `rails synchronize_properties:all`. The responsibility of the class is to download the feed and synchronize it with your database. Keep in mind that only a small number of properties change in the feed. Most, probably more than 90%, will not change.

Below are the requirements for synchronizing.

* If a property in the feed changes you should change it on your website (e.g a the type changes from Departamento to Casa)
* Don't add new property types. Just use the 4 types provided in seed.rb.
* Create a new user for each agent you find in the XML feed.
* If a property no longer appears in the feed it should be unpublished from your website. You shouldn't delete it.
* You will be working with hundreds of thousands of properties so performance and memory should be taken into account. Your code should work with a 100 or a million properties without breaking a server with 1gb of memory.
* Keep in mind some fields don't map exactly so you'll have to figure out how to best map them to your schema.

### Tests

Make sure to provide unit and/or functional tests for you code since we don't send anything to production without decent coverage and it's also a good way to document your code. We also use minitest at EasyBroker but you're free to use another test framework if you prefer. There are already several tests and fixtures provided and all should pass if you run `rails test`.

## Deliverables

You should deliver the project sharing a link to your fork (Please do not send a Pull Request). Keep in mind that the code you deliver should be considered high quality and ready to be used in a production environment and reviewed by your peers. We'll review the code to see if it's clean, clear and uses good programming practices. Also be sure to replace the notes section below with your own notes. 

## Notes

Add any notes here about your design decisions or improvements you would have made if you had more time. You also might want to consider the following questions for inspiration

* Are there any performance issues with your code or things that you could easily speed up?
* Are there any areas of your code that you think isn't that "clean"?
* Could your code easily be refactored to allow a new feed format from another source?
* If you weren't able to finish what were you able to complete and were you happy with your progress given the time constraints?

