Uniquely parses a dictionary file and extracts all unique four alpha-character sequences
from the dictionary.  By checking the history of the [requirements](https://gist.github.com/seanthehead/7220609 "requirements") the term 'unique
sequence' is understood to mean a substring of any dictionary entry that occurs in only 
one dictionary entry and only one time in that dictionary entry.  Thus, if 'zoomzoom'
appeared in the dictionary and 'zoom' were found in no other dictionary entry the output
would _not_ contain 'zoom' because it is repeated within the dictionary entry 'zoomzoom'.
