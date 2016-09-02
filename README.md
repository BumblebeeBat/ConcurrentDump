This is a concurrent version of dump, a simple database here: https://github.com/BumblebeeBat/dump

This program is supposed to be faster, but as you can see below, it is about 30% slower.


2> timer:tc(test_cdump, test, []).
{10380711,success} % this is about 10 seconds.
3> timer:tc(test_dump, test, []).
{7587552,success}  % this is about 7.5 seconds.
4> 