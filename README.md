# Cairo-matchbox-hackathon
The first AI agent trained on-chain. This project contain the following folders:
- contracts: the folder containing all the contracts for the project.
- tests: the folder containing all the tests for the cairo contracts.

Additionally, the following files can be useful: 
- Presentation: video presentation of the project.
- slides.key: slide presentation of the project.

## Installation
In order to run the project, the following commands need to be applied:
```
cd website
npm install
npm start
```
This should start http://localhost:3000/ where you will be able to interact with the cairo contracts.

## Introduction
On Starknet, several great builders have already shown that you could use an agent trained offchain to make onchain predictions.
This can already open the gates to very interesting applications to enrich onchain games.
Here we setup the next natural step to these games. Onchain training of an AI.
To show the feasibility of this concept, we attempt to construct an agent living on chain and learning to play the game of Tic Tac Toe using a classic reinforcement learning algorithm: q-learning.

## Contract architecture
There is a main contract holding the agent's intelligence or AI, we'll call it the AI contract.
A separate contract needs to be deployed for each new human player interacting with the AI contract, we'll call these the player contracts. Every time a game finishes, the Player contracts calculates the rewards associated to the finished game, and updates the state of the AI in the AI contract.
This allows the AI agent to get smarter after each human interaction.

## Q learning
The way q learning works, is that we store a huge map of states of the game board with the associated value of that state. Every time the AI needs to choose a new position on the board, it will simulate each of the possible moves, retrieve the value of these possible states and choose the action with the highest value.
At the end of the game, a reward is given to the AI depending on if it lost, won or tied. Then new values will be calculated for each of the states that the AI went through and thus the actions it took. Actions that led to wins will increase these values, while actions that led to losses will decrease them.
At first, the AI will behave randomly since all the values are set to 0, but it will get smarter as it plays.

## Additional thoughts and improvements
- To increase the number of interactions with the AI, we could add on chain self play. That would be different AI agents interacting with each other on chain and increasing each other's capabilities.
- Given the time constraints of a hackathon, there are still a lot of improvements to be done to the code. Notably:
- Increase contract protection against adversarial attacks.
- For each of the new players joining the game, there needs to be a new contract deployed. This could be added the the main AI contract in the future.
- Another improvement would be to do some additional offchain testing to prove the AI's gain in efficieny after a certain number of games played (500, 1000, 10 000).

