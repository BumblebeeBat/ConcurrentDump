This is a concurrent version of dump, a simple database here: https://github.com/BumblebeeBat/dump

This program is about 20% faster than the non-concurrent one. It could be updated to use multiple hard drives, or multiple computers connected over a network, and then it would be much faster.

```
1> timer:tc(test_cdump, test, [16]).
{4224897,success}
2> timer:tc(test_dump, test, []).
{5312891,success}
3> 
```