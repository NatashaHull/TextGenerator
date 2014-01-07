TextGenerator
=============

#History
This started as a very simple 2-gram text generator app. I then turned it into a web application using Sinatra and Redis hosted on Heroku. Once I knew everything worked, but started to worry about the coherence of most of the results I was getting, I decided to change my text generator from a 2-gram text generator, to a 3-gram text generator. From there, I created a server on AWS using Elastic Beanstalk to host the 3-gram text generator app. Lastly, I jazzed it up a little by allowing users to select the philosophers who contribute to their generated text by adding a merge method and merging the necessary philosophers together and added some css and a nice background.

#2-gram Text Generation
After considering several different options, I settled on creating a simple hash table for generating text. I parsed the text to remove most of the whitespace and separate out punctuation so it would be added separately to the hash. For the table, I made all of the keys the preceding word. For example, the string `"Early to bed and early to rise, makes a man healthy, wealthy, and wise."` would be parsed into the following hash
```ruby
{
  "." => ["Early"],
  "Early" => ["to"],
  "to" => ["bed", "rise"],
  "bed" => ["and"],
  "and" => ["early", "wise"],
  "early" => ["to"],
  "rise" => [","],
  "," => ["makes", "wealthy", "and"],
  "makes" => ["a"],
  "a" => ["man"],
  "man" => ["healthy"],
  "healthy" => [","],
  "wealthy" => [","],
  "wise" => ["."]
}
```
Because I created the hash this way, I can simply generate a random next word given a current word by calling `sample` on the array I get by looking up the current word in the hash. Lastly, I made it so there's a 60% chance it will stop generating text every time it generates adds a period to the current text. The source code is [here](https://github.com/NatashaHull/TextGenerator/blob/master/lib/2gram_word_table.rb).

#2-gram to 3-gram
The 3-gram text generator works similarly to the 2-gram text generator. There are two main differences. First, the keys in the main hash were two word phrases. Second, the first change is only true if the key is not a period. For example, the string `"Early to bed and early to rise, makes a man healthy, wealthy, and wise."` would be parsed into the following hash
```ruby
{
  "." => ["Early"],
  ". Early" => ["to"],
  "Early to" => ["bed"],
  "to bed" => ["and"],
  "bed and" => ["early"],
  "and early" => ["to"],
  "early to" => ["rise"],
  "to rise" => [","],
  "rise ," => ["makes"],
  ", makes" => ["a"],
  "makes a" => ["man"],
  "a man" => ["healthy"]
  "man healthy" => [","],
  "healthy ," => ["wealthy"],
  ", wealthy" => [","],
  "wealthy ," => ["and"],
  ", and" => ["wise"],
  "wise" => ["."]
}
```
This meant that, when generating text, my text generator needs to know the two preceeding words to generate any word, unless the preceeding word is a period. Other than that, my method for generating text is essentially the same. The source code is [here](https://github.com/NatashaHull/TextGenerator/blob/master/lib/3gram_word_table.rb).

#Credits
Design: The background pattern for this website is taken from [http://subtlepatterns.com/](http://subtlepatterns.com/)

Philosophical Texts: The philosophical texts are downloaded and redacted (I removed Project Gutenberg text) from Project Gutenberg. These philosophical texts are Hume's "Treatise on Human Nature", Kant's "Critique of Pure Reason", Soctrates's "Euthyphro", Descartes's "Meditations on First Philosophy", and Locke's "Essay Concerning Human Understanding."

Images from Wikimedia, EducaMadrid, Encyclopedia Britannica, aquarianagrarian.blogspot.com.
