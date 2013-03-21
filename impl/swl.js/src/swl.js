function d(n, s) {
  var c = 0;
  while (n > 0) {
      c += Math.floor(Math.random() * s) + 1;
      n--;
  }
  return c;
}

Room = function() {
    this.init = function(desc, exits) {
        this.desc = desc;
        this.exits = exits;
        this.arrows = 0;
        this.carcasses = 0;
        this.cans = 0;
        this.tokens = 0;
        this.guano = 0;
        this.bats = 0;
        this.pits = 0;
    };
};

Wumpus = function() {
    this.init = function() {
        this.room = d(1, 100);
        this.asleep = (d(1, 2) === 1);
    };
}

SuperWumpusLand = function() {
    this.init = function(tty) {
        this.tty = tty;

        this.rooms = [];
        this.visited = [];
        this.wumpi = [];

        this.name = 'user';  // Actually, it's the *player's* name...
        this.roomNo = 0;
        
        this.arrows = 0;
        this.hides = 0;
        this.cans = 0;
        this.tokens = 0;

        this.batbgon = 0;
        this.codliver = 0;
        this.camo = 0;
        this.grip = 0;
        this.ustink = 0;
        
        this.subway = false;
        
        this.skip = false;
        this.moved = false;

        this.gameState = 'stateTitleScreen';

        var loc_adj = [
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
        ];

        var loc_noun = [
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
        ];

        var backlinks = [];
        for (var i = 0; i < 10; i++)
        {
            for (var j = 0; j < 10; j++)
            {
                var r = i * 10 + j + 1;
                var r1 = d(1,100);
                var r2 = d(1,100);
                var r3 = d(1,100);
                var room = new Room();
                room.init(loc_adj[i] + ' ' + loc_noun[j], [r1, r2, r3]);
                this.rooms[r] = room;
                backlinks.push([r1, r]);
                backlinks.push([r2, r]);
                backlinks.push([r3, r]);              
            }
        }
        
        for (var i = 0; i < backlinks.length; i++) {
            var src = backlinks[i][0];
            var dest = backlinks[i][1];
            var exit = Math.floor(Math.random() * 3);
            this.rooms[src].exits[exit] = dest;
        }

        for (var i = 0; i < 42; i++)
        {
            if (i < 33) { this.rooms[d(1,100)].arrows++; }
            if (i < 15) { this.rooms[d(1,100)].cans++; }
            if (i < 10) { this.rooms[d(1,100)].tokens++; }
            this.rooms[d(1,100)].guano++;
        }

        for (var i = 0; i < 5; i++)
        {
            this.wumpi[i] = new Wumpus();
            this.wumpi[i].init();
        }
        for (var i = 0; i < 11; i++)
        {
            this.rooms[d(1,100)].bats = 1;
        }
        for (var i = 0; i < 7; i++)
        {
            this.rooms[d(1,100)].pits = 1;
        }

        this.roomNo = d(1,100);
        this.arrows = 1;

        tty.write("SUPER WUMPUS LAND\n\n");
        this.pause('statePrompt');
    };

    this.pause = function(nextState) {
        this.tty.write("\n[Press ENTER to continue.]  ");
        this.gameState = nextState;
    };

    this.show = function() {
        var room = this.rooms[this.roomNo];
        var desc = this.roomNo + '. ' + room.desc;

        var self = this;
        var print = function(str) {
            self.tty.write(str);
        };

        this.tty.reset();

        this.visited[this.roomNo] = 1;
        print(desc + "\n");
        for (var i = 0; i < desc.length; i++) {
            print('-');
        }
        print("\n\n");

        if (room.arrows === 1) {
          print("There is an arrow lying here.\n");
        } else if (room.arrows > 0) {
          print("There are " + room.arrows + " arrows lying here.\n");
        }

        if (room.carcasses === 1) {
            print("There is a dead Wumpus carcass here.\n");
        } else if (room.carcasses > 1) {
            print("There are " + room.carcasses + " dead carcasses of ex-Wumpi here.\n");
        }

        if (room.cans === 1) {
            print("There is an unlabelled aerosol can here.\n");
        } else if (room.cans > 1) {
            print("There are " + room.cans + " unlabelled aerosol cans here.\n");
        }

        if (room.tokens === 1) {
            print("A subway token lies on the ground here.\n");
        } else if (room.tokens > 1) {
            print("" + room.tokens + " subway tokens lie on the ground here.\n");
        }

        if (room.guano > 0) {
            print("\nThere is a ");
            if (room.guano === 1) { print("small"); }
            else if (room.guano === 2) { print("sizable"); }
            else if (room.guano === 3) { print("large"); }
            else if (room.guano === 4) { print("huge"); }
            else { print("gigantic"); }
            print(" pile of Wumpus dung here.\n");
        }

        print("\n");

        var smellWumpus = false;
        for (var i = 0; i < this.wumpi.length; i++) {
            if (this.wumpi[i].room === this.roomNo) {
                if (!this.wumpi[i].asleep) {
                    if (this.subway) {
                        print("* Right outside the train window is a Wumpus!\n");
                    } else if (this.camo) {
                        print("* Good thing the Wumpus here can't see you.\n");
                    } else {
                        print("* Oh No, " + this.name + "!  A Wumpus ATE YOU UP!!!\n");
                        if (this.codliver > 0) {
                            print("  ...and immediately BARFED YOU BACK OUT!!!!\n");
                        } else {
                            this.pause('stateGameOver');
                            return false;
                        }
                    }
                } else {
                    print("* There's a Wumpus asleep RIGHT IN FRONT OF YOU!!\n");
                }
            }
            for (var exit = 0; exit < 3; exit++) {
                if (room.exits[exit] === this.wumpi[i].room) {
                    smellWumpus = true;
                    break;
                }
            }
        }
        if (smellWumpus && !this.ustink) {
            print("* I smell a Wumpus!\n");
        }

        if (room.bats > 0) {
            if (this.subway) {
                print("* Super Bats flutter out of the path of the subway train.\n");
            } else if (this.batbgon > 0) {
                print("* Super Bats in this location stay well away from your awful stench!\n");
            } else {
                print("* Zap!  Super Bat Snatch!  Elsewheresville for you!\n");
                this.roomNo = d(1,100);
                this.skip = 1;
                this.pause('statePrompt');
                return false;
            }
        }
        var batsNearby = false;
        for (var i = 0; i <= 2; i++)
        {
            if (this.rooms[room.exits[i]].bats > 0)
                batsNearby = true;
        }
        if (batsNearby) {
            print("* Bats nearby!\n");
        }

        if (room.pits > 0) {
            if (this.subway) {
                print("* The subway rails take a curving path around a bottomless pit here.\n");
            } else if (this.grip > 0) {
                print("* You deftly stick to the edge of the bottomless pit!\n");
            } else {
                print("* Yiiiieeee!!!  Fell in a pit!\n");
                this.pause('stateGameOver');
                return false;
            }
        }
        var aDraft = false;
        for (var i = 0; i <= 2; i++)
        {
            if (this.rooms[room.exits[i]].pits > 0)
                aDraft = true;
        }
        if (aDraft) {
            print("* I feel a draft...\n");
        }

        print("\nFrom here you can make passage to\n");
        for (var i = 0; i <= 2; i++)
        {
          print("  [" + room.exits[i] + "] ");
          if (this.visited[room.exits[i]]) {
              print(this.rooms[room.exits[i]].desc);
              if (this.rooms[room.exits[i]].bats > 0) { print(" (Bats)"); }
              if (this.rooms[room.exits[i]].pits > 0) { print(" (Pit)"); }
              print("\n");
          } else
          {
              print("(not yet visited)\n");
          }
        }
        print("\n");
        return true;
    };

    this.ask = function() {
        var room = this.rooms[this.roomNo];
        var self = this;
        var print = function(str) {
            self.tty.write(str);
        };

        if (this.arrows === 1)
        {
          print("  [F]ire your crooked arrow\n");
        }
        else if (this.arrows > 1)
        {
          print("  [F]ire one of your " + this.arrows + " crooked arrows\n");
        }

        if (this.cans === 1)
        {
          print("  [A]pply the contents of the aerosol can on yourself\n");
        }
        else if (this.cans > 0)
        {
          print("  [A]pply one of your " + this.cans + " aerosol cans on yourself\n");
        }

        if (this.tokens == 1)
        {
          print("  [R]ide the subway with your token\n");
        }
        else if (this.tokens > 0)
        {
          print("  [R]ide the subway with one of your " + this.tokens + " tokens\n");
        }

        if (room.arrows > 0 || room.cans > 0 || room.tokens > 0)
        {
          print("  [P]ick up the items from this location\n");
        }

        if (room.carcasses === 1)
        {
          print("  [S]kin the ex-Wumpus for it's hide\n");
        }
        else if (room.carcasses > 1)
        {
          print("  [S]kin the ex-Wumpi for their hides\n");
        }
        if (room.guano > 0)
        {
          print("  [D]ig through the Wumpus dung looking for items\n");
        }

        print("  [I]nventory and Score\n\n");
        print("  [Q]uit\n\n");
        print("What would you like to do next, " + this.name + "?  ");
        
        this.gameState = 'stateProcessCommand';
    };

    this.moveWumpi = function() {
        var self = this;
        var print = function(str) {
            self.tty.write(str);
        };

        for (var i = 0; i < this.wumpi.length; i++) {
            var wumpus = this.wumpi[i];
            if (wumpus.room === 0) {
                if (d(1, 5) === 1) {
                    // restart wumpus
                    wumpus.room = d(1, 100);
                    while (wumpus.room === this.roomNo) {
                        wumpus.room = d(1, 100);
                    }
                    wumpus.asleep = false;
                }
                continue;
            }
            if (wumpus.asleep) {
                if (d(1, 4) === 1) {
                    wumpus.asleep = false;
                    if (d(1, 5) !== 1) {
                        this.rooms[wumpus.room].guano++;
                    }
                }
            } else {
                if (d(1, 3) === 1) {
                    var dest = this.rooms[wumpus.room].exits[d(1,3)-1];
                    if (dest !== this.roomNo || !this.moved) {
                        wumpus.room = dest;
                        if (dest === this.roomNo) {
                            print("From around a corner, a hungry-looking Wumpus appears!!\n");
                            this.pause();
                        }
                    }
                }
                if (d(1,8) === 1) { wumpus.asleep = true; }
                if (d(1,8) === 1) { this.rooms[wumpus.room].guano++; }
            }
        }
    };

    /* -*-*-*- GAME STATES -*-*-*- */

    this.statePrompt = function(input) {
        if (this.show()) {
            this.ask();
        }
    };

    this.stateGameOver = function(input) {
        this.tty.write("Game over, " + this.name + ".\n");
    };

    this.stateProcessCommand = function(input) {
        var self = this;
        var print = function(str) {
            self.tty.write(str);
        };
        var room = this.rooms[this.roomNo];

        input = input.toUpperCase();
        if (input === 'Q') {
            this.pause('stateGameOver');
            return;
        } else if (input === 'I') {
            //alert('ya');
            print("Your score is 7.");
            this.pause('statePrompt');
            return;
        } else if (input === 'A' && this.cans > 0) {
            this.cans--;
            print("\n  * * * *** fshhhhhhhhhhfft *** * * *\n\n");
            //sleep 1;
            print("  Turns out it was ... ");
            //sleep 2;
            var c = d(1, 7);
            if (c === 1) {
              print("new car smell!\n");
            } else if (c === 2) {
              print("\"Bat-B-Gon!\"\n");
              this.batbgon += d(4,4);
            } else if (c === 3) {
              print("pepper spray!!!!  AIIIGGGGHHHH!!!\n\n");
              //sleep 1;
              print("  AAAAIIIIIIIIIIIIIIGGGGGGHHHHH!!!\n\n");
              //sleep 2;
              print("  AAAAAAAIIIIIIIIIIIIIIIIIIIIGGGGGGGGHHHHHH!!!\n\n");
              //sleep 3;
              print("  AAAAAAAAAAIIIIIIIIIIIIIIIIIIIIIIIIIIGGGGGGGGGGHHHHHHH!!!\n\n");
              //sleep 4;
              print("You run around screaming for a while until the burning subsides...\n");
              this.roomNo = d(1,100);
            } else if (c === 4) {
              print("\"Super Sticky Grip Goop\"!\n");
              this.grip += d(4,4);
            } else if (c === 5) {
              print("cod liver oil!\n");
              this.codliver += d(4,4);
            } else if (c === 6) {
              print("camoflage paint!\n");
              this.camo += d(4,4);
            } else if (c === 7) {
              print("\"E-Z-F Oven Cleaner!\"\n");
              if (this.grip > 0) this.grip = 1;
              if (this.camo > 0) this.camo = 1;
              if (this.codliver > 0) this.codliver = 1;
              if (this.batbgon > 0) this.batbgon = 1;
            }
            this.pause('statePrompt');
            return;
        } else if (input === 'D' && room.guano > 0) {
            this.ustink += d(3,3);
            room.guano--;
            if (d(1,3)  == 1) { room.arrows++; }
            if (d(1,6)  == 1) { room.cans++; }
            if (d(1,12) == 1) { room.tokens++; }
            print("\nEw.  You now stink so bad that you can't smell anything but yourself.\n");
            this.pause('statePrompt');
            return;
        } else if (input === 'P') {
            this.arrows += room.arrows; room.arrows = 0;
            this.cans += room.cans; room.cans = 0;
            this.tokens += room.tokens; room.tokens = 0;
        } else {
            var dest = parseInt(input, 10);
            if (dest !== NaN) {
                if (room.exits[0] === dest ||
                    room.exits[1] === dest ||
                    room.exits[2] === dest) {
                    this.roomNo = dest;
                    this.moved = true;
                }
            }
        }

        this.moveWumpi();

        if (this.show()) {
            this.ask();
        }
    };

    this.handleInput = function(input) {
        this[this.gameState](input);
    };
};
