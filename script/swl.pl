#!/usr/bin/env perl

### BEGIN swl.pl ###

# SUPER WUMPUS LAND v1.0-2013.0326
# Copyright (c)2000-2013, Chris Pressey, Cat's Eye Technologies.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notices, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notices, this list of conditions, and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#  3. Neither the names of the copyright holders nor the names of their
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
# COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# usage: [perl] swl[.pl]

### PREAMBLE ###

use strict qw(vars refs subs);

### GLOBALS ###

my @room;
my @visited;
my @wumpus;
my @pit;
my @bat;

my $name;      # Actually, it's the *player's* name...

my $room;

my $aros;
my $hides;
my $cans;
my $tokens;

my $batbgon;
my $codliver;
my $camo;
my $grip;
my $ustink;

my $subway;

my $done;
my $skip;
my $moved;

### SUBROUTINES ###

sub d
{
  my $n = shift;
  my $s = shift;

  my $c = 0;
  while ($n--) { $c += int(rand($s)) + 1; }
  return $c;
}

sub cls
{
  # Change following line to clear the screen on your system.
  printf "%c[2J", 27;                     # ANSI terminal
  # printf "%c", 12;                      # Teletype
  # system "cls";                         # external program
}

sub pause
{
  print "\n[Press ENTER to continue.]  ";
  my $foo = <STDIN>;
}

sub splash
{
  cls();
  print "*" x 72 . "\n";
  for(my $i = 1; $i <= 20; $i++)
  {
    if ($i == 6)
    {
      print "*                S U P E R     W U M P U S     L A N D                 *\n";
    }
    elsif ($i == 7)
    {
      print "*                ---------     -----------     -------                 *\n";
    }
    elsif ($i == 9)
    {
      print "*                            v1.0-2013.0326                            *\n";
    }
    elsif ($i == 14)
    {
      print "*              by Chris Pressey, Cat's Eye Technologies                *\n";
    }
    elsif ($i == 16)
    {
      print "*              Based on an original game by Gregory Yob                *\n";
    } else
    {
      print "*" . ' ' x 70  . "*\n";
    }
  }
  print "*" x 72 . "\n";
  pause();
}

sub score
{
  cls();
  print "Scorecard for $name\n";
  print "==============" . "=" x length($name) . "\n\n";

  my $h1 = sprintf("%3d", $hides);
  my $s1 = sprintf("%9d", $hides * 25);
  print "Wumpus Hides       $h1 x  25 = $s1\n";

  my $h2 = sprintf("%3d", $aros);
  my $s2 = sprintf("%9d", $aros * 2);
  print "Arrows Remaining   $h2 x   2 = $s2\n";

  my $h4 = sprintf("%3d", $cans);
  my $s4 = sprintf("%9d", $cans * 3);
  print "Aerosol Cans       $h4 x   3 = $s4\n";

  my $h5 = sprintf("%3d", $tokens);
  my $s5 = sprintf("%9d", $tokens * 5);
  print "Subway Tokens      $h5 x   5 = $s5\n";

  my $h3 = 0;
  for (my $i = 1; $i <= 100; $i++)
  {
    $h3++ if $visited[$i];
  }
  $h3 = sprintf("%3d", $h3);
  my $s3 = sprintf("%9d", $h3);
  print "Locations Visited  $h3 x   1 = $s3\n";

  my $tot = sprintf("%9d", $s1 + $s2 + $s3 + $s4 + $s5);
  print "                               ---------\n";
  print "Total                          $tot\n\n";

}

sub show
{
  my $q = $room[$room];
  my $desc = $room . '. ' . $q->[0];

  cls();

  $visited[$room] = 1;

  print $desc . "\n";
  print "-" x length($desc) . "\n\n";

  if ($room[$room]->[4] == 1)
  {
    print "There is an arrow lying here.\n";
  }
  elsif ($room[$room]->[4] > 0)
  {
    print "There are $room[$room]->[4] arrows lying here.\n";
  }

  if ($room[$room]->[5] == 1)
  {
    print "There is a dead Wumpus carcass here.\n";
  }
  elsif ($room[$room]->[5] > 0)
  {
    print "There are $room[$room]->[5] dead carcasses of ex-Wumpi here.\n";
  }

  if ($room[$room]->[6] == 1)
  {
    print "There is an unlabelled aerosol can here.\n";
  }
  elsif ($room[$room]->[6] > 0)
  {
    print "There are $room[$room]->[6] unlabelled aerosol cans here.\n";
  }

  if ($room[$room]->[7] == 1)
  {
    print "A subway token lies on the ground here.\n";
  }
  elsif ($room[$room]->[7] > 0)
  {
    print "$room[$room]->[7] subway tokens lie on the ground here.\n";
  }

  if ($room[$room]->[8] > 0)
  {
    print "\nThere is a ";
    if ($room[$room]->[8] == 1) { print "small"; }
    elsif ($room[$room]->[8] == 2) { print "sizable"; }
    elsif ($room[$room]->[8] == 3) { print "large"; }
    elsif ($room[$room]->[8] == 4) { print "huge"; }
    elsif ($room[$room]->[8] == 5) { print "gigantic"; }
    else
    {
      print "super " x ($room[$room]->[8] - 5) . "big";
    }
    print " pile of Wumpus dung here.\n";
  }

  print "\n";

  for(my $i = 0; $i < 20; $i++)
  {
    if ($wumpus[$i]->[0] == $room)
    {
      if ($wumpus[$i]->[1] != 0)
      {
        if ($subway)
        {
          print "* Right outside the train window is a Wumpus!\n";
        }
        elsif ($camo)
        {
          print "* Good thing the Wumpus here can't see you.\n";
        } else
        {
          print "* Oh No, $name!  A Wumpus ATE YOU UP!!!\n";
          if ($codliver)
          {
            print "  ...and immediately BARFED YOU BACK OUT!!!!\n";
          } else
          {
            pause();
            $done = 1;
            return;
          }
        }
      } else
      {
        print "* There's a Wumpus asleep RIGHT IN FRONT OF YOU!!\n";
      }
    }
    if ( ($room[$room]->[1] == $wumpus[$i]->[0]) ||
         ($room[$room]->[2] == $wumpus[$i]->[0]) ||
         ($room[$room]->[3] == $wumpus[$i]->[0]) )
    {
      print "* I smell a Wumpus!\n" if not $ustink;
    }

    if ($bat[$i] == $room)
    {
      if ($subway)
      {
        print "* Super Bats flutter out of the path of the subway train.\n";
      }
      elsif ($batbgon)
      {
        print "* Super Bats in this location stay well away from your awful stench!\n";
      } else
      {
        print "* Zap!  Super Bat Snatch!  Elsewheresville for you!\n";
        pause();
        $room = d(1,100);
        $skip = 1;
        return;
      }
    }
    if ( ($room[$room]->[1] == $bat[$i]) ||
         ($room[$room]->[2] == $bat[$i]) ||
         ($room[$room]->[3] == $bat[$i]) )
    {
      print "* Bats nearby!\n";
    }

    if ($pit[$i] == $room)
    {
      if ($subway)
      {
        print "* The subway rails take a curving path around a bottomless pit here.\n";
      }
      elsif ($grip)
      {
        print "* You deftly stick to the edge of the bottomless pit!\n";
      } else
      {
        print "* Yiiiieeee!!!  Fell in a pit!\n";
        pause();
        $done = 1;
        return;
      }
    }
    if ( ($room[$room]->[1] == $pit[$i]) ||
         ($room[$room]->[2] == $pit[$i]) ||
         ($room[$room]->[3] == $pit[$i]) )
    {
      print "* I feel a draft...\n";
    }
  }

  print "\nFrom here you can make passage to\n";
  for(my $i = 1; $i <= 3; $i++)
  {
    print "  \[$q->[$i]\] ";
    if ($visited[$q->[$i]])
    {
      print "$room[$q->[$i]]->[0]";
      for(my $j = 0; $j < 20; $j++) { if ($bat[$j] == $q->[$i]) { print " (Bats)"; last; } }
      for(my $j = 0; $j < 20; $j++) { if ($pit[$j] == $q->[$i]) { print " (Pit)"; last; } }
      print "\n";
    } else
    {
      print "(not yet visited)\n";
    }
  }
  print "\n";

}

sub ask
{
  if ($aros == 1)
  {
    print "  [F]ire your crooked arrow\n";
  }
  elsif ($aros > 1)
  {
    print "  [F]ire one of your $aros crooked arrows\n";
  }
  if ($cans == 1)
  {
    print "  [A]pply the contents of the aerosol can on yourself\n";
  }
  elsif ($cans > 0)
  {
    print "  [A]pply one of your $cans aerosol cans on yourself\n";
  }
  if ($tokens == 1)
  {
    print "  [R]ide the subway with your token\n";
  }
  elsif ($tokens > 0)
  {
    print "  [R]ide the subway with one of your $tokens tokens\n";
  }
  if ($room[$room]->[4] > 0 or $room[$room]->[6] > 0 or $room[$room]->[7] > 0)
  {
    print "  [P]ick up the items from this location\n";
  }
  if ($room[$room]->[5] == 1)
  {
    print "  [S]kin the ex-Wumpus for it's hide\n";
  }
  elsif ($room[$room]->[5] > 1)
  {
    print "  [S]kin the ex-Wumpi for their hides\n";
  }
  if ($room[$room]->[8] > 0)
  {
    print "  [D]ig through the Wumpus dung looking for items\n";
  }
  print "  [I]nventory and Score\n\n";
  print "  [Q]uit\n\n";
  print "What would you like to do next, $name?  ";
  my $r = <STDIN>;
  chomp($r);
  $r = uc $r;

  if ($r eq 'Q')
  {
    $done = 1;
  }
  elsif ($r eq 'I')
  {
    score();
    pause();
  }
  elsif ($r eq 'D' and $room[$room]->[8] > 0)
  {
    $ustink += d(3,3);
    $room[$room]->[8]--;
    if (d(1,3)  == 1) { $room[$room]->[4]++; }
    if (d(1,6)  == 1) { $room[$room]->[6]++; }
    if (d(1,12) == 1) { $room[$room]->[7]++; }
    print "\nEw.  You now stink so bad that you can't smell anything but yourself.\n";
    pause();
  }
  elsif ($r eq 'A' and $cans > 0)
  {
    $cans--;
    print "\n  * * * *** fshhhhhhhhhhfft *** * * *\n\n";
    sleep 1;
    print "  Turns out it was ... ";
    sleep 2;

    my $c = d(1,7);
    if ($c == 1)
    {
      print "new car smell!\n";
    }
    elsif ($c == 2)
    {
      print "\"Bat-B-Gon!\"\n";
      $batbgon += d(4,4);
    }
    elsif ($c == 3)
    {
      print "pepper spray!!!!  AIIIGGGGHHHH!!!\n\n";
      sleep 1;
      print "  AAAAIIIIIIIIIIIIIIGGGGGGHHHHH!!!\n\n";
      sleep 2;
      print "  AAAAAAAIIIIIIIIIIIIIIIIIIIIGGGGGGGGHHHHHH!!!\n\n";
      sleep 3;
      print "  AAAAAAAAAAIIIIIIIIIIIIIIIIIIIIIIIIIIGGGGGGGGGGHHHHHHH!!!\n\n";
      sleep 4;
      print "You run around screaming for a while until the burning subsides...\n";
      $room = d(1,100);
    }
    elsif ($c == 4)
    {
      print "\"Super Sticky Grip Goop\"!\n";
      $grip += d(4,4);
    }
    elsif ($c == 5)
    {
      print "cod liver oil!\n";
      $codliver += d(4,4);
    }
    elsif ($c == 6)
    {
      print "camoflage paint!\n";
      $camo += d(4,4);
    }
    elsif ($c == 7)
    {
      print "\"E-Z-F Oven Cleaner!\"\n";
      $grip = 1 if $grip;
      $camo = 1 if $camo;
      $codliver = 1 if $codliver;
      $batbgon = 1 if $batbgon;
    }
    pause();
  }
  elsif ($r eq 'P' and ($room[$room]->[4] > 0 or $room[$room]->[6] > 0 or $room[$room]->[7] > 0))
  {
    $aros += $room[$room]->[4];
    $room[$room]->[4] = 0;
    $cans += $room[$room]->[6];
    $room[$room]->[6] = 0;
    $tokens += $room[$room]->[7];
    $room[$room]->[7] = 0;
  }
  elsif ($r eq 'S' and $room[$room]->[5] > 0)
  {
    $hides += $room[$room]->[5];
    $room[$room]->[5] = 0;
  }
  elsif ($r eq 'R' and $tokens > 0)
  {
    print "Where do you want to take the subway to? [1-100]  ";
    my $r = <STDIN>;
    $r = int($r);
    if ($r >= 1 and $r <= 100)
    {
      $tokens--;
      print "\n  \"All aboard!\"\n\n";
      sleep 2;
      for(my $q = 1; $q <= 3; $q++) { print ((' ' x $q) x $q . "...chug chug...\n"); sleep 1; }
      for(my $i = 1; $i <= 3; $i++)
      {
        $room = d(1,100);
        $subway = 1;
        show();
        for(my $q = 1; $q <= 3; $q++) { print ((' ' x $i) x $q . "...chug chug...\n"); sleep 1; }
        $subway = 0;
      }
      print "\n  \"Next stop, $r, $room[$r]->[0]...\"";
      sleep 3;
      $room = $r;
    } else
    {
      print "OK, keep your token, if that's the way you feel.\n";
      pause();
    }
  }
  elsif ($r eq 'F' and $aros > 0)
  {
    my @it = ();
    my $d = 1; my $n = 1;
    while($d)
    {
      print "Enter the ";
      if ($n == 1) { print "first"; }
      elsif ($n == 2) { print "second"; }
      elsif ($n == 3) { print "third"; }
      else { print "${n}th"; }
      print " location to ";
      if ($n == 1) { print "fire in"; }
      else { print "continue "; }
      print "to, or 0 to commence>  ";
      $d = <STDIN>;
      chomp($d); $d = int($d); $n++;
      if ($d > 0) { push @it, $d; }
    }
    print "\nTwang!... ";  $aros--;
    my $l = $room;
    while ($#it >= 0)
    {
      $d = shift @it;
      if (($l == $d) ||
          ($room[$l]->[1] == $d) ||  
          ($room[$l]->[2] == $d) ||  
          ($room[$l]->[3] == $d))
      {
        $l = $d;

        for(my $i = 0; $i < 20; $i++)
        {
          if ($wumpus[$i]->[0] == $l)
          {
            sleep 3;
            print "...*SPLAK*!  Got something!\n";
            $wumpus[$i]->[0] = 0;
            $room[$l]->[5]++;
            pause();
            return;
          }
        }

        if ($room == $l)
        {
          sleep 3;
          print "...*ZOINKS!*\n\nYou shot yourself in the foot, $name!!!\n";
          $done = 1;
          pause();
          return;
        }

        sleep 1;
        print "...whoosh... ";

      } else
      {
        sleep 1;
        print "...*clang*\n\n";
        @it = ();
        $room[$l]->[4]++ if d(1,3) == 1;
        pause();
        return;
      }
    }

    my $flag = 0;
    for(my $i = 0; $i < 20; $i++)
    {
      $flag = 1 if $pit[$i] == $l;
    }

    if (not $flag)
    {
      sleep 1;
      print "...*thud*";
      $room[$l]->[4]++;
    };

    sleep 1; print "\n";
    pause();
  }
  elsif (int($r) > 0)
  {
    if ( ($room[$room]->[1] == int($r)) ||
         ($room[$room]->[2] == int($r)) ||
         ($room[$room]->[3] == int($r)) )
    {
      $room = int($r);
      $moved = 1;
    }
  }
}

sub move_wumpi
{
  my $i;
  for($i = 0; $i < 20; $i++)
  {
    if ($wumpus[$i]->[0] != 0)
    {
      if ($wumpus[$i]->[1] == 0)
      {
        if (d(1,4) == 1)
        {
          $wumpus[$i]->[1] = 1;  # wake up
          $room[$wumpus[$i]->[0]]->[8]++ unless d(1,5)==1;
        }
      } else
      {
        if (d(1,3) == 1)
        {
          my $q = $room[$wumpus[$i]->[0]]->[d(1,3)];
          if ($q != $room or not $moved)
          {
            $wumpus[$i]->[0] = $q;
            if ($q == $room)
            {
              print "From around a corner, a hungry-looking Wumpus appears!!\n";
              pause();
            }
          }
        }
        if (d(1,8) == 1) { $wumpus[$i]->[1] = 0; }  # sleep
        if (d(1,8) == 1) { $room[$wumpus[$i]->[0]]->[8]++; }   # crap
      }
    }
  }
  # restart dead wumpi
  for($i = 0; $i < 5; $i++)
  {
    if ($wumpus[$i]->[0] == 0 and d(1,5) == 1)
    {
      $wumpus[$i]->[0] = d(1,100);
      while ($wumpus[$i]->[0] == $room) { $wumpus[$i]->[0] = d(1,100); }
      $wumpus[$i]->[1] = 1;
    }
  }
}

sub entropy
{
  if ($batbgon)
  {
    if (--$batbgon == 1) { print "Your \"Bat-B-Gon\" is wearing off.\n"; pause(); }
    if ($batbgon == 0) { print "Your \"Bat-B-Gon\" has worn off.\n"; pause(); }
  }
  if ($codliver)
  {
    if (--$codliver == 1) { print "The cod liver oil seems to be wearing off.\n"; pause(); }
    if ($codliver == 0) { print "The cod liver oil seems to have all worn off.\n"; pause(); }
  }
  if ($camo)
  {
    if (--$camo == 1) { print "Your camoflage is peeling.\n"; pause(); }
    if ($camo == 0) { print "Your camoflage is gone.\n"; pause(); }
  }
  if ($grip)
  {
    if (--$grip == 1) { print "Your hands and feet are starting to feel less sticky.\n"; pause(); }
    if ($grip == 0) { print "Your hands and feet are no longer sticky.\n"; pause(); }
  }
  if ($ustink)
  {
    if (--$ustink == 0) { print "Your sense of smell seems to have returned.\n"; pause(); }
  }
}

sub mixup
{
  my @a = @_;
  my @b = ();
  while ($#a >= 0)
  {
    my $i = d(1,$#a+1)-1;
    push @b, $a[$i];
    @a = (@a[0..$i-1], @a[$i+1..$#a]);
  }
  return @b;
}

### INIT ###

srand();
splash();
cls();

print "\n\n\n\n\n\n\n\n\n\n\n                 What is your name?  ";
$name = <STDIN>;
chomp($name);
$name =~ s/^\s*//o;
$name =~ s/\s*^//o;

if ($name eq '')
{
  my $r = d(1,4);
  if ($r == 1) { $name = "Cuddles"; }
  elsif ($r == 2) { $name = "Sweetie-Pie"; }
  elsif ($r == 3) { $name = "Snookums"; }
  elsif ($r == 4) { $name = "Honeybunch"; }

  print "  Fine, I'll just call you $name then.\n";
  pause();
}

### MAIN ###

my $play = 1;
while ($play)
{
  my @loc_adj = mixup
  (
    'Rocky',
    'Stony',
    'Dusty',
    'Scenic',
    'Dreary',
    'Scorched',
    'Ruinous',
    'Breezy',
    'Humid',
    'Depressing'
  );

  my @loc_noun = mixup
  (
    'Plain',
    'Steppes',
    'Path',
    'Trail',
    'Passage',
    'Foothills',
    'Cave',
    'Cavern',
    'Ravine',
    'Expanse'
  );

  my $i; my $j;
  
  for($i = 0; $i < 10; $i++)
  {
    for($j = 0; $j < 10; $j++)
    {
      my $r = $i * 10 + $j + 1;
      my $r1 = d(1,100);
      my $r2 = d(1,100);
      my $r3 = d(1,100);
      $room[$r] =
      [
        $loc_adj[$i] . ' ' . $loc_noun[$j],
        $r1, $r2, $r3,
        0,          # arrows
        0,          # hides
        0,          # aerosol cans
        0,          # tokens
        0,          # guano
      ];

      $room[$r1]->[1] = $r;  # backlink
      $room[$r2]->[1] = $r;
      $room[$r3]->[1] = $r;
    }
  }

  for($i = 0; $i < 42; $i++)
  {
    $room[d(1,100)]->[4]++ if $i < 33;
    $room[d(1,100)]->[6]++ if $i < 15;
    $room[d(1,100)]->[7]++ if $i < 10;
    $room[d(1,100)]->[8]++;
  }

  for($i = 0; $i < 20; $i++)
  {
    $wumpus[$i]->[0] = d(1,100);
    $wumpus[$i]->[1] = d(1,2)-1;
    $wumpus[$i]->[0] = 0 if ($i > 4);
    $bat[$i] = d(1,100);
    $bat[$i] = 0 if ($i > 10);
    $pit[$i] = d(1,100);
    $pit[$i] = 0 if ($i > 6);
  }

  @visited = ();

  $room = d(1,100);
  $aros = 1;
  $hides = 0;
  $cans = 0;
  $tokens = 0;

  $batbgon = 0;
  $codliver = 0;
  $camo = 0;
  $grip = 0;
  $ustink = 0;

  $done = 0;
  $skip = 0;

  while (not $done)
  {
    $moved = 0;
    show();
    ask() if not $done and not $skip;
    move_wumpi();
    entropy();
    $skip = 0;
  }

  score();
  print "\nYou want to play again, right, $name?  ";
  my $r = <STDIN>;
  $play = 0 if $r =~ /^\s*n/i;
}

cls();

### END ###
