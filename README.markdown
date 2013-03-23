Super Wumpus Land
=================

This is the reference distribution of Super Wumpus Land, a computer game
by Chris Pressey, based on a legendary game by Gregory Yob.

It contains original version of Super Wumpus Land, written as a Perl
script, in the `scripts` directory.

It also contains a conversion in Javascript, for playing in a web browser,
in the `impl/swl.js` directory.  This implementation uses modules from
`yoob.js` to simulate the terminal in an HTML5 canvas.

Changelog-a-go-go
-----------------

*   v2000.xxxx
    
    Initial version, the script written in Perl 5, `swl.pl`.
    
*   v2004.0227
    
    Version not differing significantly from initial version.
    
*   v1.0-2007.1216 a.k.a. v2007.1216
    
    Version not differing significantly from initial version.
    
*   v1.1-2013.0323
    
    Added conversion to Javascript, `swl.js`.
    
    Fixed bug in Perl version where you could spray an aerosol can
    that you didn't actually have.
    
    Perl version still bore the version number 1.0.  Both versions
    oddly bore the version number "1.0-2013.0326".
    
*   v1.1-2013.0324
    
    Fixed version number in both versions to 1.1-2013.0324.
    
    Fixed bug in Javascript version where you effectively never
    disembarked from the subway train, once on it.
    
    Made clearer from the room description that you are aboard
    the subway train, when you are.  (Both versions.)
