import { Contract } from "starknet";
import contractAbi from "./abis/board.json";
import BOARD_ADDRESS from "../starknet/contract_addresses";

export const getContractState = async () => {
  //   const contract = new Contract(contractAbi, BOARD_ADDRESS);
  const contract = new Contract(
    contractAbi,
    "0x05dc40aa4246be3ad5bed99fccdae5de4e865d5642a789c7aefa16fd6d2a2139"
  );

  if (contract === undefined) {
    console.log("no contract");
    return null;
  }

  //   console.log("there is a contract");
  //   console.log(contract);

  //   const board = await contract.view_board(0);
  //   console.log(parseBoard(board));

  const board = await getAllPositions(contract);
  //   const game_number = await contract.view_game_number();
  //   console.log(game_number);
  //   const number_moves = await contract.view_num_moves();
  //   console.log(number_moves);
  console.log(board);

  const winner = await getWinner(contract);

  return [board, winner];
};

const getWinner = async (contract) => {
  const winner = await contract.view_winner();
  console.log(winner.winner.words[0]);
  return winner.winner.words[0];
};

const parseBoard = (res) => {
  if (res.board_value.words[0] === 0) {
    return "";
  } else if (res.board_value.words[0] === 1) {
    return "O";
  } else if (res.board_value.words[0] === 2) {
    return "X";
  } else {
    return "";
  }
};

const getAllPositions = async (contract) => {
  let board = [];
  for (let i = 0; i < 9; i++) {
    const position_state = await contract.view_board(i);
    // console.log(i, parseBoard(position_state));
    // console.log(parseBoard(position_state));
    board.push(parseBoard(position_state));
  }
  const newArr = [];
  //   console.log("board");
  //   console.log(board);
  while (board.length) newArr.push(board.splice(0, 3));
  //   console.log("new array");
  //   console.log(newArr);
  return newArr;
};
