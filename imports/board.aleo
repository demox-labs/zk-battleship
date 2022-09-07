program board.aleo;

// Battleship boards are represented by 8x8 squares.
// A u64 is all that is required to represent a hit or a miss on a single board.
// Starting from the top row, left to right, a hit is 1 and a miss is 0.
// A first move resulting in a hit in row 1, column 3 would be:
// 00100000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
// A second u64 is needed to represent which squares have been played, with 1s being played squares and 0s being
// unplayed squares.
record board_state:
    owner as address.private;
    gates as u64.private;
    // the hits and misses registered on the opponent's board
    hits_and_misses as u64.private;
    // the squares that have been played on the opponent's board
    played_tiles as u64.private;
    ships as u64.private; // the ship bitstring representing all ship positions on your own board
    player_1 as address.private;
    player_2 as address.private;
    game_started as boolean.private;

// input r0 (u64): u64 equivalent of the bitstring representation of a game board, 8x8.
// input r1 (address): the address of the opponent.
function initialize_board:
    input r0 as u64.private;
    input r1 as address.private;

    cast self.caller 0u64 0u64 0u64 r0 self.caller r1 false into r2 as board_state.record;

    output r2 as board_state.record;

// input r0 (board_state.record): the record of the board to start. A board can only be started once.
// returns a new board state record that has been started. Will fail if this board has been started before.
function start_board:
    input r0 as board_state.record;

    // ensure this board hasn't been used to start a game before
    assert.eq false r0.game_started;

    cast r0.owner r0.gates r0.hits_and_misses r0.played_tiles r0.ships r0.player_1 r0.player_2 true into r1 as board_state.record;

    output r1 as board_state.record;

// input r0 (board_state.record): the record of the board to update
// input r1 (u64): the u64 equivalent of a bitstring fire coordinate to send to the opponent.
// returns a new board state record that includes all the played tiles. Fails if r1 has been played before.
function update_played_tiles:
    input r0 as board_state.record;
    input r1 as u64.private; // your next move

    // need to make sure r1 is a valid move. Only one bit of r1 should be flipped.
    sub r1 1u64 into r2;
    // bitwise and operation
    and r1 r2 into r3;
    assert.eq 0u64 r3;

    // need to make sure r1 is a valid move given the played_tiles. no bits should overlap.
    and r0.played_tiles r1 into r4;
    assert.eq 0u64 r4;

    or r0.played_tiles r1 into r5; // new played tiles

    cast r0.owner r0.gates r0.hits_and_misses r5 r0.ships r0.player_1 r0.player_2 r0.game_started into r6 as board_state.record;

    output r6 as board_state.record;

// input r0 (board_state.record): the record of the board to update
// input r1 (u64): the u64 equivalent of a bitstring of whether this player's previous move was a hit or miss.
// returns a new board state record that includes all the hits and misses.
function update_hits_and_misses:
    input r0 as board_state.record;
    input r1 as u64.private;

    or r0.hits_and_misses r1 into r2; // updated hits and misses

    cast r0.owner r0.gates r2 r0.played_tiles r0.ships r0.player_1 r0.player_2 r0.game_started into r3 as board_state.record;

    output r3 as board_state.record;
