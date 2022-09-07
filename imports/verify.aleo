program verify.aleo;

// We're using the c_ prefix to denote the special closure function type.
// input r0 (u64): an input that corresponds to a u64 bitstring
// returns the number of "flipped" bits.
// E.g. 17870283321406128128u64, in binary 11111000 00000000 00000000 00000000 00000000 00000000 00000000 00000000,
// returns 5u64;
closure c_bitcount:
    input r0 as u64;

    div r0 2u64 into r1;
    div r0 4u64 into r2;
    div r0 8u64 into r3;

    and r1 8608480567731124087u64 into r4;
    and r2 3689348814741910323u64 into r5;
    and r3 1229782938247303441u64 into r6;

    sub r0 r4 into r7;
    sub r7 r5 into r8;
    sub r8 r6 into r9;

    div r9 16u64 into r10;
    add r9 r10 into r11;
    and r11 1085102592571150095u64 into r12;
    rem r12 255u64 into r13;

    output r13 as u64;

// input r0 (u64): the u64 representation of a ship's placement in an 8x8 grid.
// input r1 (u64): the u64 representation of a ship's bitstring, either horizontally or vertically.
// E.g. a ship of length 3's bit string horizontally would be: 000111 = 7u64. Vertically, the bit string would be:
// 10000000100000001 = 65793u64.
// returns boolean of whether all the flipped bits in r0 are "adjacent". Horizontally, this means all flipped bits are
// directly next to each other (111). Vertically, this means all flipped bits are separated by 7 unflipped bits
// (10000000100000001).
closure c_adjacency_check:
    input r0 as u64;
    input r1 as u64;

    // this may result in 0
    div r0 r1 into r2;
    // subtracting 1 from 0 will cause an underflow, so we should check for this edge case.
    is.eq r2 0u64 into r3;
    // if the above division resulted in 0, we know the adjacency check should return false.
    // Setting to r4 to 3 (11) will guarantee failure here.
    ternary r3 3u64 r2 into r4;

    sub r4 1u64 into r5;
    and r4 r5 into r6;

    is.eq r6 0u64 into r7;

    output r7 as boolean;

// input r0 (u64): the u64 representation of a ship's placement in an 8x8 grid.
// input r1 (u64): the u64 representation of a ship's bitstring horizontally
// returns boolean of whether adjacent flipped bits don't split a row of size 8.
// E.g. 111000000 has adjacent flipped bits but splits a row: 00000001 11000000
closure c_horizontal_check:
    input r0 as u64;
    input r1 as u64;

    rem r0 255u64 into r2;
    // this may result in 0
    div r2 r1 into r3;

    // subtracting 1 from 0 will cause an underflow
    is.eq r3 0u64 into r4;
    // setting to 3 will guarantee failure
    ternary r4 3u64 r3 into r5;
    sub r5 1u64 into r6;
    and r5 r6 into r7;

    is.eq r7 0u64 into r8;
    
    output r8 as boolean;

// input r0 (u64): the u64 representation of a ship's placement in an 8x8 grid.
// input r1 (u64): the length of the placed ship
// input r2 (u64): the u64 equivalent of a ship's horizontal bitstring representation
// input r3 (u64): the u64 equivalent of a ship's vertical bitstring representation
// returns boolean whether the ship placement is valid or not
function validate_ship_placement:
    input r0 as u64.private; // Ship placement on board
    input r1 as u64.private; // Ship length
    input r2 as u64.private; // Horizontal ship bitstring
    input r3 as u64.private; // Vertical ship bitstring

    // check bitcount -- all other validations depend on the bitcount being correct
    call c_bitcount r0 into r4; // how many bits in the ship placement
    assert.eq r4 r1;

    // if horizontal:
    call c_adjacency_check r0 r2 into r5; // true if bits are adjacent horizontally
    call c_horizontal_check r0 r2 into r6; // true if those horizontal bits are not split across rows
    and r5 r6 into r7; // true if bits are adjacent horizontally and not split across rows

    // if vertical:
    call c_adjacency_check r0 r3 into r8; // true if bits are adjacent vertically

    or r7 r8 into r9; // ship is valid if it is vertically or horizontally valid

    output r9 as boolean.private;

// input r0 (u64): the u64 representation of a carrier's placement in an 8x8 grid. Length = 5.
// input r1 (u64): the u64 representation of a battleship's placement in an 8x8 grid. Length = 4.
// input r2 (u64): the u64 representation of a cruiser's placement in an 8x8 grid. Length = 3.
// input r3 (u64): the u64 representation of a destroyer's placement in an 8x8 grid. Length = 2.
// returns the u64 representation of all the ships' placements in an 8x8 grid. This function will fail
// if any of the ship placements overlap each other.
function create_board:
    input r0 as u64.private; // Carrier, length 5
    input r1 as u64.private; // Battleship, length 4
    input r2 as u64.private; // Cruiser, length 3
    input r3 as u64.private; // Destroyer, length 2

    // bitwise combine the ship placements together
    or r0 r1 into r4;
    or r2 r3 into r5;
    or r4 r5 into r6; // full bitwise combination of ships

    call c_bitcount r6 into r7;
    assert.eq r7 14u64; // given 4 individually-valid ships, a valid combination should yield exactly 14 flipped bits.

    output r6 as u64.private;