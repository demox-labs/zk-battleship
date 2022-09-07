import board.aleo;
import move.aleo;
import verify.aleo;

// The 'battleship.aleo' program.
program battleship.aleo;

// input r0 (u64): the u64 representation of a carrier's placement in an 8x8 grid. Length = 5.
// input r1 (u64): the u64 representation of a battleship's placement in an 8x8 grid. Length = 4.
// input r2 (u64): the u64 representation of a cruiser's placement in an 8x8 grid. Length = 3.
// input r3 (u64): the u64 representation of a destroyer's placement in an 8x8 grid. Length = 2.
// input r4 (address): the address of the opponent.
function initialize_board:
    input r0 as u64.private; // Carrier, length 5
    input r1 as u64.private; // Battleship, length 4
    input r2 as u64.private; // Cruiser, length 3
    input r3 as u64.private; // Destroyer, length 2
    input r4 as address.private;

    // verify that each individual ship placement bitstring is valid
    call verify.aleo/validate_ship_placement r0 5u64 31u64 4311810305u64 into r5;
    assert.eq r5 true;
    call verify.aleo/validate_ship_placement r1 4u64 15u64 16843009u64 into r6;
    assert.eq r6 true;
    call verify.aleo/validate_ship_placement r2 3u64 7u64 65793u64 into r7;
    assert.eq r7 true;
    call verify.aleo/validate_ship_placement r3 2u64 3u64 257u64 into r8;
    assert.eq r8 true;

    // create the board with all the ship placements combined
    call verify.aleo/create_board r0 r1 r2 r3 into r9;

    // initialize the board state record
    call board.aleo/initialize_board r9 r4 into r10;

    output r10 as board.aleo/board_state.record;

// input r0 (board_state.record): the board record to start a game with.
// returns an updated board state record that has been started. This board cannot be used to start any other games.
// returns a dummy move record owned by the opponent.
// This function commits a given board to a game with an opponent and creates the initial dummy move.
function offer_battleship:
    input r0 as board.aleo/board_state.record;

    call board.aleo/start_board r0 into r1;
    call move.aleo/start_game r0.player_2 into r2;

    output r1 as board.aleo/board_state.record;
    output r2 as move.aleo/move.record;

// input r0 (board_state.record): the board record to play the game with.
// input r1 (move.record): move record to play to begin the game. This should be the dummy move record created
// from offer_battleship.
// returns updated board_state.record that has been started and can no longer be used to join or start new games.
// returns dummy move record owned by the opponent.
function start_battleship:
    input r0 as board.aleo/board_state.record;
    input r1 as move.aleo/move.record;

    // validate that the move players and board players match each other.
    assert.eq r0.player_1 r1.player_2;
    assert.eq r0.player_2 r1.player_1;

    call board.aleo/start_board r0 into r2;
    call move.aleo/start_game r0.player_2 into r3;

    output r2 as board.aleo/board_state.record;
    output r3 as move.aleo/move.record;

// input r0 (board_state.record): the board record to update
// input r1 (move.record): the incoming move from the opponent
// input r2 (u64): the u64 equivalent of the bitwise representation of the next coordinate to play on
// the opponent's board.
// returns updated board record.
// returns new move record owned by opponent.
function play:
    input r0 as board.aleo/board_state.record;
    input r1 as move.aleo/move.record;
    input r2 as u64.private;

    // verify the board has been started. This prevents players from starting a game and then creating
    // a brand new board to play with.
    assert.eq r0.game_started true;

    // validate that the move players and board players match each other.
    assert.eq r0.player_1 r1.player_2;
    assert.eq r0.player_2 r1.player_1;

    // play coordinate on own board. will fail if not a valid move
    call board.aleo/update_played_tiles r0 r2 into r3;

    // update own board with result of last shot
    call board.aleo/update_hits_and_misses r3 r1.prev_hit_or_miss into r4;

    // assess whether incoming move firing coordinate is a hit
    and r1.incoming_fire_coordinate r0.ships into r5;

    call move.aleo/create_move r1 r2 r5 into r6;

    output r4 as board.aleo/board_state.record;
    output r6 as move.aleo/move.record;