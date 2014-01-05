TextGenerator
=============

#History
This started as a very simple 2-gram text generator app. I then turned it into a web application using Sinatra and Redis hosted on Heroku. Once I knew everything worked, but started to worry about the coherence of most of the results I was getting, I decided to change my text generator from a 2-gram text generator, to a 3-gram text generator. From there, I created a server on AWS using Elastic Beanstalk to host the 3-gram text generator app. Lastly, I jazzed it up a little by allowing users to select the philosophers who contribute to their generated text by adding a merge method and merging the necessary philosophers together and added some css and a nice background.
