import styles from "./TicTacToe.module.css";
import { useEffect, useState } from "react";
import { getContractState } from "../../starknet/getContractState";
import { useStarknet } from "@starknet-react/core";
import { play } from "../../starknet/writeContract";
import { SettingsInputAntennaTwoTone } from "@mui/icons-material";
import { Button } from "../general.styles";
import { Box } from "@mui/system";

const players = {
  CPU: {
    SYM: "O",
    NAME: "CPU",
  },
  HUMAN: {
    SYM: "X",
    NAME: "You",
  },
};

function sleep(milliseconds) {
  const date = Date.now();
  let currentDate = null;
  do {
    currentDate = Date.now();
  } while (currentDate - date < milliseconds);
}

export default function TicTacToe() {
  // const [board, setBoard] = useState(Array(9).fill(""));
  const [board, setBoard] = useState([
    ["", "", ""],
    ["", "", ""],
    ["", "", ""],
  ]);
  const [winner, setWinner] = useState();
  const [isCPUNext, setIsCPUNext] = useState(false);
  // const [winner, setWinner] = useState(null);

  function playFn(arrayIndex, index) {
    if (isCPUNext) return;
    if (winner) return;
    // console.log(arrayIndex, index);
    const position = arrayIndex * 3 + index;
    play(position);
    // board[arrayIndex][index] = players?.HUMAN?.SYM;
    // setBoard((board) => [...board]);
    // checkWinner();
    // setIsCPUNext(true);
  }

  const handleGetStorage = async () => {
    const [board, winner] = await getContractState();
    setBoard(board);
    setWinner(winner);
  };

  //   useEffect(() => {
  //     console.log("update of the board");
  //     console.log("update of the board");
  //   }, [board]);

  //   useEffect(() => {
  //     if (winner) return;
  //     if (isCPUNext) {
  //       cPUPlay();
  //     }
  //   }, [isCPUNext]);

  function cPUPlay() {
    if (winner) return;
    // sleep(1000);

    const cPUMove = getCPUTurn();

    board[cPUMove.arrayIndex][cPUMove.index] = players?.CPU?.SYM;

    setBoard((board) => [...board]);
    checkWinner();
    setIsCPUNext(false);
  }

  function getCPUTurn() {
    const emptyIndexes = [];
    board.forEach((row, arrayIndex) => {
      row.forEach((cell, index) => {
        if (cell === "") {
          emptyIndexes.push({ arrayIndex, index });
        }
      });
    });
    const randomIndex = Math.floor(Math.random() * emptyIndexes.length);
    return emptyIndexes[randomIndex];
  }

  function checkWinner() {
    // check same row
    for (let index = 0; index < board.length; index++) {
      const row = board[index];
      if (row.every((cell) => cell === players?.CPU?.SYM)) {
        setWinner(players?.CPU?.NAME);
        return;
      } else if (row.every((cell) => cell === players?.HUMAN?.SYM)) {
        setWinner(players?.HUMAN?.NAME);
        return;
      }
    }

    // check same column
    for (let i = 0; i < 3; i++) {
      const column = board.map((row) => row[i]);
      if (column.every((cell) => cell === players?.CPU?.SYM)) {
        setWinner(players?.CPU?.NAME);
        return;
      } else if (column.every((cell) => cell === players?.HUMAN?.SYM)) {
        setWinner(players?.HUMAN?.NAME);
        return;
      }
    }

    // check same diagonal
    const diagonal1 = [board[0][0], board[1][1], board[2][2]];
    const diagonal2 = [board[0][2], board[1][1], board[2][0]];
    if (diagonal1.every((cell) => cell === players?.CPU?.SYM)) {
      setWinner(players?.CPU?.NAME);
      return;
    } else if (diagonal1.every((cell) => cell === players?.HUMAN?.SYM)) {
      setWinner(players?.HUMAN?.NAME);
      return;
    } else if (diagonal2.every((cell) => cell === players?.CPU?.SYM)) {
      setWinner(players?.CPU?.NAME);
      return;
    } else if (diagonal2.every((cell) => cell === players?.HUMAN?.SYM)) {
      setWinner(players?.HUMAN?.NAME);
      return;
    } else if (board.flat().every((cell) => cell !== "")) {
      setWinner("draw");
      return;
    } else {
      setWinner(null);
      return;
    }
  }

  // function displayWinner() {
  //   if (winner === "draw") {
  //     return "It's a draw!";
  //   } else if (winner) {
  //     return `${winner} won!`;
  //   }
  // }

  function displayWinner() {
    const winnerText = {
      0: "No games played yet ...",
      1: "Good job humans, you won !",
      2: "Skynet for the win",
      3: "It's a tie !",
    };
    console.log("ayme4ric");
    console.log(winnerText[winner]);
    return winnerText[winner];
    // return "You are the winner";
  }

  function playAgainFn() {
    setBoard([
      ["", "", ""],
      ["", "", ""],
      ["", "", ""],
    ]);
    setWinner(null);
    setIsCPUNext(false);
  }

  return (
    <div>
      <Box display="flex" justifyContent={"center"} flexDirection={"column"}>
        <Box component="h2" display="flex" justifyContent={"center"}>
          <div>{displayWinner()}</div>
        </Box>
        <div className={styles.container}>
          <div className={styles.col}>
            <span onClick={() => playFn(0, 0)} className={styles.cell}>
              {board[0][0]}
            </span>
            <span onClick={() => playFn(0, 1)} className={styles.cell}>
              {board[0][1]}
            </span>
            <span onClick={() => playFn(0, 2)} className={styles.cell}>
              {board[0][2]}
            </span>
          </div>
          <div className={styles.col}>
            <span onClick={() => playFn(1, 0)} className={styles.cell}>
              {board[1][0]}
            </span>
            <span onClick={() => playFn(1, 1)} className={styles.cell}>
              {board[1][1]}
            </span>
            <span onClick={() => playFn(1, 2)} className={styles.cell}>
              {board[1][2]}
            </span>
          </div>
          <div className={styles.col}>
            <span onClick={() => playFn(2, 0)} className={styles.cell}>
              {board[2][0]}
            </span>
            <span onClick={() => playFn(2, 1)} className={styles.cell}>
              {board[2][1]}
            </span>
            <span onClick={() => playFn(2, 2)} className={styles.cell}>
              {board[2][2]}
            </span>
          </div>
        </div>
        <Box mt={2} display={"flex"} justifyContent={"center"}>
          <Button onClick={() => handleGetStorage()}> Get Storage </Button>
        </Box>
      </Box>
    </div>
  );
}

export const GetStateButton = () => {
  // const [contractContent, setContractContent] = useState();

  return (
    <button
      onClick={() => {
        getContractState();
      }}
    >
      Contract Content
    </button>
  );
};

export const PlayButton = () => {
  const { account } = useStarknet();

  // const [contractContent, setContractContent] = useState();

  return (
    <button
      onClick={() => {
        play(account);
      }}
    >
      Play
    </button>
  );
};
