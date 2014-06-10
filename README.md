# Stancer

## Summary

Show how UK MPs and Parties voted on Issues.

## Background

Knowing how politicians voted on individual motions generally isn't
particularly useful. What most people really want to know is how a
person, or political grouping, voted on **all** motions relating to a
particular issue.

``Stancer`` is a tool that lets you store lists of individual motions
making up an Issue, along with how strongly they should contribute to
it, and then see clearly how any person, party, or any kind of grouping
voted on that issue.

``Stancer-UK`` is a version of this working on UK vote data. It's built
on GitHub Pages, and can be viewed at http://ukvotes.discomposer.com/

## Details

1. We take voting data and Policy positions from [Public Whip](http://www.publicwhip.org.uk/) 
and [TheyWorkForYou](http://theyworkforyou.com/), transform the underlying
motion data into [Popolo vote format](http://popoloproject.com/specs/motion.html), 
and access that via the [VoteIt API](https://github.com/tmtmtmtm/voteit-api). 
The code for doing all that can be found in the 
[voteit-data-pw](https://github.com/tmtmtmtm/voteit-data-pw) repo.

2. From your [Stancer](https://github.com/tmtmtmtm/stancer-pw), copy
   ``issues.json``, ``mpstances.json``, and ``partystances.json`` into
the ``_data`` directory. (Note that currently Jekyll requires that you
also rename these as .yaml files rather than .json!)

3. Generate stub pages for parties, people, and issues. Jekyll requires
   a minimal template for each file you want to display, even if that
will be generated entirely out of data. You can create these files
using:
    * ruby _bin/generate_mp_pages.rb
    * ruby _bin/generate_party_pages.rb
    * ruby _bin/generate_issue_pages.rb

## DIY

If you want to do your own version of this, feel free to dig into
everything here and see how far you get (most of the logic is in the
[layouts](_layouts/)), but you'll probably be better contacting me — at
least until I write up a lot more of how all the parts hang together.

VoteIt and Popolo should cope well with lots of very different voting
scenarios, but the Stancer is currently very UK specific. Splitting out a
more generic component is a high priority.

More details on it all can be found at http://discomposer.com/stancer/

