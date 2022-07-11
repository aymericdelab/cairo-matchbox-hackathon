import "./App.css";
// import { Starknet } from "./Starknet/Starknet";
// import { Game } from "./TicTacToe/TicTacToe";
// import ButtonAppBar from "./components/AppBar/AppBar";
import { Box } from "@mui/system";
import {
  ConnectButton,
  DemoAccount,
} from "./components/ConnectButton/ConnectButton";
import {
  StarknetProvider,
  getInstalledInjectedConnectors,
} from "@starknet-react/core";
import {
  Game,
  GetStateButton,
  PlayButton,
} from "./components/TicTacToe/TicTacToe";
import TicTacToe from "./components/TicTacToe/TicTacToeFunc";

function App() {
  const connectors = getInstalledInjectedConnectors();
  return (
    <StarknetProvider connectors={connectors}>
      {/* <GetStateButton></GetStateButton>
      <PlayButton></PlayButton> */}
      <Box>
        <DemoAccount></DemoAccount>
      </Box>
      {/* <Box>
        <Game></Game>
      </Box> */}
      <Box mt={2}>
        <TicTacToe></TicTacToe>
      </Box>
    </StarknetProvider>
  );

  //   return <Starknet></Starknet>;

  //   return <Game></Game>;
}

export default App;
