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
        this.codLiver = 0;
        this.camo = 0;
        this.grip = 0;
        this.ustink = 0;
        
        this.subway = undefined;
        
        this.done = undefined;
        this.skip = undefined;
        this.moved = false;

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
            // backlink exits
            if (this.rooms[r1] !== undefined) {
                this.rooms[r1].exits[0] = r;
            }
            if (this.rooms[r2] !== undefined) {
                this.rooms[r2].exits[0] = r;
            }
            if (this.rooms[r3] !== undefined) {
                this.rooms[r3].exits[0] = r;
            }
          }
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
            this.wumpi[i] = d(1,100);
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
        this.show();
        this.ask();
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

        if (room.guano > 0)
        {
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
            if (room.exits[i] === this.wumpi[i]) {
                smellWumpus = true;
                break;
            }
        }
        if (smellWumpus && !this.ustink) {
            print("* I smell a Wumpus!\n");
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
    };
    
    this.pause = function() {
        this.tty.write("\n[Press ENTER to continue.]  ");
        this.paused = true;
    };

    this.handleInput = function(input) {
        if (this.paused) {
            this.paused = false;
            this.show();
            this.ask();
            return;
        }

        var self = this;
        var print = function(str) {
            self.tty.write(str);
        };
        var room = this.rooms[this.roomNo];

        input = input.toUpperCase();
        if (input === 'Q') {
            this.done = true;
            return;
        } else if (input === 'I') {
            //alert('ya');
            print("Your score is 7.");
            this.pause();
            return;
        } else if (input === 'D' && room.guano > 0) {
            this.ustink += d(3,3);
            room.guano--;
            if (d(1,3)  == 1) { room.arrows++; }
            if (d(1,6)  == 1) { room.cans++; }
            if (d(1,12) == 1) { room.tokens++; }
            print("\nEw.  You now stink so bad that you can't smell anything but yourself.\n");
            this.pause();
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
        this.show();
        this.ask();
    };
}