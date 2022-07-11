import { Contract } from "starknet";
import contractAbi from "./abis/board.json";
import { useStarknet } from "@starknet-react/core";
import { connect } from "@argent/get-starknet";
import { BOARD_ADDRESS } from "./contract_addresses";

export const play = async (position) => {
  // Let the user pick a wallet (on button click)
  const starknet = await connect();
  // Check if connection was successful
  if (starknet.isConnected) {
    console.log("is connected");

    const { code, transaction_hash } = await starknet.account.execute(
      {
        // contractAddress: BOARD_ADDRESS,
        contractAddress:
          "0x05dc40aa4246be3ad5bed99fccdae5de4e865d5642a789c7aefa16fd6d2a2139",
        entrypoint: "play",
        calldata: [
          position,
          "0x014bfa8d5ed2eb342c1e5beb10b4b761d55796036b8a8a52eca770f73075192a",
        ],
      },
      undefined,
      { maxFee: "10000000" }
    );
    console.log(code, transaction_hash);
  } else {
    console.log("not connected");

    console.log(starknet.account);
  }

  // console.log("In play function, account: ", account);
  // const contract = new Contract(
  //   contractAbi,
  //   "0x03b9c62b347e3b63e9344b080eee4b824364650337e66fbbd28c70547d9d7be7"
  // );

  // if (contract === undefined) {
  //   console.log("no contract");
  //   return null;
  // }

  // console.log("there is a contract");
  // console.log(contract);

  // //   const res = await contract.play(
  // //     4,
  // //     "0x014bfa8d5ed2eb342c1e5beb10b4b761d55796036b8a8a52eca770f73075192a",
  // //     (maxFee = 0.00002)
  // //   );

  // console.log(code, transaction_hash);
};
