program move.aleo;

record move:
    owner as address.private;
    gates as u64.private;
    incoming_fire_coordinate as u64.private;
    player_1 as address.private;
    player_2 as address.private;
    prev_hit_or_miss as u64.private;

// input r0 (move.record): the move record created by the opponent.
// input r1 (u64): the u64 representation of incoming_fire_coordinate, the bitstring fire coordinate
// to send to the opponent.
// input r2 (u64): the u64 representation of prev_hit_or_miss, this player's previous fire coordinate as a hit or miss.
// One flipped bit indicates a hit. No flipped bits indicates a miss.
// returns new move record owned by the opponent.
function create_move:
    input r0 as move.record;
    input r1 as u64.private;
    input r2 as u64.private;

    // a new move record should be created and owned by the opponent.
    is.eq r0.owner r0.player_1 into r3;
    ternary r3 r0.player_2 r0.player_1 into r4;

    cast r4 r0.gates r1 r0.player_2 r0.player_1 r2 into r5 as move.record;

    output r5 as move.record;

// input r0 (address): the address of the second player
// returns move record owned by the opponent. Note, this move record contains
// dummy fire coordinates and previous hit or miss.
function start_game:
    // self.caller will be player 1
    input r0 as address.private; // player 2

    cast r0 0u64 0u64 self.caller r0 0u64 into r1 as move.record;

    output r1 as move.record;