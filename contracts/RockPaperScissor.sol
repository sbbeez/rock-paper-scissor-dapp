// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract RockPaperScissor {
    // Player choices that player can make
    enum PlayerChoice {
        ROCK,
        PAPER,
        SCISSOR,
        NOTMADE
    }

    enum GameStatus {
        WAITING_FOR_OTHER_PLAYER,
        START_GAME
    }

    enum GameResults {
        HAS_WINNER,
        TIE
    }

    struct Player {
        address addr;
        PlayerChoice choice;
    }
    // players opposition are made in two different arrays
    Player[] private playerOne;
    Player[] private playerTwo;

    // last index for the players list
    uint256 lastPlayerIndex = 0;

    /// Index's address and sender address is not matching
    error IncorrectIndexOrInvalidPlayer();

    // if player wants to enter the game, player should have atleast 0.001 ether
    function enterGame()
        public
        payable
        returns (GameStatus status, uint256 playerIndex)
    {
        require(msg.value == 1 ether);
        Player memory newPlayer = Player({
            addr: msg.sender,
            choice: PlayerChoice.NOTMADE
        });
        if (playerOne.length == playerTwo.length) {
            playerOne.push(newPlayer);
            return (GameStatus.WAITING_FOR_OTHER_PLAYER, lastPlayerIndex);
        } else {
            playerTwo.push(newPlayer);
            lastPlayerIndex++;
            return (GameStatus.START_GAME, lastPlayerIndex - 1);
        }
    }

    function transferFunds(Player memory _player, uint amount) private {
        payable(_player.addr).transfer(amount);
    }

    function _findWinnerAndTransferFunds(
        Player memory _playerOne,
        Player memory _playerTwo
    ) private {
        if (_playerOne.choice == _playerTwo.choice) {
            // transfer funds back to both players
            transferFunds(_playerOne, address(this).balance / 2);
            transferFunds(_playerTwo, address(this).balance);
        }
        PlayerChoice playerOneChoice = _playerOne.choice;
        PlayerChoice playerTwoChoice = _playerTwo.choice;
        if (
            (playerOneChoice == PlayerChoice.ROCK &&
                playerTwoChoice == PlayerChoice.SCISSOR) ||
            (playerOneChoice == PlayerChoice.SCISSOR &&
                playerTwoChoice == PlayerChoice.PAPER) ||
            (playerOneChoice == PlayerChoice.PAPER &&
                playerTwoChoice == PlayerChoice.ROCK)
        ) {
            transferFunds(_playerOne, address(this).balance);
        } else {
            transferFunds(_playerTwo, address(this).balance);
        }
    }

    function makeChoice(uint256 _playerIndex, PlayerChoice _choice) public {
        if (playerOne[_playerIndex].addr == msg.sender) {
            playerOne[_playerIndex].choice = _choice;
        } else if (playerTwo[_playerIndex].addr == msg.sender) {
            playerTwo[_playerIndex].choice = _choice;
        } else {
            revert IncorrectIndexOrInvalidPlayer();
        }
        if (
            playerOne[_playerIndex].choice != PlayerChoice.NOTMADE &&
            playerTwo[_playerIndex].choice != PlayerChoice.NOTMADE
        ) {
            _findWinnerAndTransferFunds(playerOne[_playerIndex], playerTwo[_playerIndex]);
        }
    }
}
