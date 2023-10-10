// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/**
 * Unlike regular blackjack, it is extremely difficult to hide the dealer’s card, so have everyone have a fully open hand. 
 * Real blackjack is usually played with multiple decks to make card counting less effective, so you can have random number 
 * generator produce a random number from [2-10] but keep in mind ten, jack, queen, and king are all 10, 
 * so you need to make the probabilities proportional. Similarly, and Ace can be a 1 or an 11. The dealer must hit until they are at least 21. 
 * Because smart contracts cannot move state forward on their own, anyone can call dealerNextMove() to keep the game moving forward 
 * if it is the dealer’s turn. In a real application, you’d need an offchain computer to keep the dealer going, 
 * but let’s not worry about this for now. You should force players to make their move within 10 blocks to avoid anyone holding the game up.
 */