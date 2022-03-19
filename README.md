# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Ruby version
2.6.5

Third-party dependencies
PostgreSQL
Elasticsearch



# Signing In

Common-or-garden JWT usage.

* Squirt a POST at /login, with params[user][email]=your user's email, and params[user][password] their password.
    - (Don't forget to inspect your request headers and make sure you don't have an Authorization header left over from previous requests! Delete it if so.)
* Inspect the response. If email/password were correct:
    - The response body will be JSON: user: { id, email, token: 'Bearer xxxxx' }.
    - The response headers will contain an 'Authorization' header, with value 'Bearer xxxxx'.
* That 'xxxxx' bit is a JWT. Use either one, they're identical. 
    - Shove this header and its value in every subsequent request header: 'Authorization': 'Bearer xxxxx'. Sorted.
