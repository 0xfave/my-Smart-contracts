// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/**
 * Use ERC1155 tokens to simulate a deck of cards that can take on any value from 1-25 inclusive. 
 * Each player starts with a 5x5 2d array of the numbers 1-25 randomly arranged. 
 * Every n blocks, players can mint a new card which has a random number. 
 * Whoever gets the first 5 in a row (bingo) wins.
 */