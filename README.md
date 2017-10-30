# parrot

The state of the art in ham detection in IRC is that people tell their clients what words to get alerted on. It should not be hard to do better.

I stuck the simplest machine learning library I found (https://hackage.haskell.org/package/hext-0.1.0.4, trained on #haskell logs from http://tunes.org/~nef/logs/haskell/) into the simplest IRC bot library I found (https://hackage.haskell.org/package/simpleirc) and told it to yell what new #haskell lines are likely to be replied to by which person into #parrot on Freenode.

Results log:
  - Train on three years of logs. Eats all my 3-7 GB of free RAM.
  - Train on three years of log lines that contain my name. 100 MB RAM, and it works, but as expected, the false positive rate is through the roof - it learned that I'd reply to every other line.
  - Train on one year of logs. Eats about 3 GB, but I can use the computer for other things, so I let it run for several minutes before aborting the learning.
  - Train on three years of logs, learn only whether I will reply. Eats all my free RAM.
