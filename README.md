How to play Solitaire:

The goal of the game is to form 4 stacks of cards in each suite in the order A,2,3,4,5,6,7,8,9,10,J,Q,K. These stacks are located in the top-right corner of the screen.

The deck is located at the top-left corner of the screen and cards are drawn one at a time.

Any face-up card can be placed on another face-up card of next-higher rank provided it is of opposite color (e.g. A black 5 may be placed on a red 6). If multiple cards are face-up in a stack, the stack must be moved as a single unit.

When there are no more face-up cards in a column, the top face-down card is turned face-up.

Only a king may fill an empty column.

---

Controls:

D-pad - moves the cursor

Select Button - draws a card from the deck

Start Button - starts the game

A Button - selects/moves cards

B Button - does nothing

---

The cursor points to the top-left.

To select a card, move the cursor to the card you want to select and press A. To then move a card, move the cursor to where you want the card to be and press A again.

Note that if you're moving a card on top of another card, you must have the cursor pointed at where the selected card will be after the move, not necessarily the card below it. This means that pressing A when the cursor is on the top 1/3 of an existing card will result in an invalid move.

The below diagram shows in green where a valid move will be. Note also that pressing A when the cursor is below any existing card will result in the card moving to the closest spot in the column provided that the move is a legal move in Solitaire.

![movement diagram](https://github.com/BuschEric97/NES_Solitaire/assets/36495578/92ea1819-cda7-4be9-9c13-28614a252c6f)

---

Scoring:

Moving to column from draw pile: +5 points

Moving to discard piles: +10 points

Flipping over hidden card: +5 points

Moving from discard piles: -15 points

Refreshing deck (after first time): -30 points

Every 256 frames: -1 point