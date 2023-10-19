```ruby
Task_1
  * Text: "Lorem ipsum dolor sit amet, 
          consectetur adipiscing elit,
          sed do eiusmod tempor
          incididunt ut labore et dolor."
  * Word: "dolor."
  - Equal:  [16]
  - Bigger: [5 6 10 12]
  - Lesser: [0 1 2 3 4 7 8 9 13 15]


Task_2
  - Word: "dolor"
  - Text (length): 109

    + simple (length): 2
    * time (ns):       670
    * comparisons:     342

    + kmp (length):    2
    * time (ns):       834
    * comparisons:     226


  - Word: "dolor"
  - Text (length): 8126

    + simple (length): 7
    * time (ns):       14536
    * comparisons:     24607

    + kmp (length):    7
    * time (ns):       23121
    * comparisons:     16451


  - Word: "dolor"
  - Text (length): 76641

    + simple (length): 54
    * time (ns):       132585
    * comparisons:     232084

    + kmp (length):    54
    * time (ns):       211266
    * comparisons:     155140
```


