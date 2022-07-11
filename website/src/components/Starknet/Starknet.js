import "../App.css";
import {
  StarknetProvider,
  getInstalledInjectedConnectors,
} from "@starknet-react/core";
import { useConnectors } from "@starknet-react/core";
import { connect } from "@argent/get-starknet";
import { useStarknet } from "@starknet-react/core";
// import { useStarknetCall } from "@starknet-react/core";
import { useStarknetBlock } from "@starknet-react/core";
// import { useContract } from "@starknet-react/core";
import contractAbi from "../../contract_abi.json";
import {
  // deployContract,
  // CompiledContract,
  // waitForTx,
  Contract,
  // Abi,
  // utils,
  // hashMessage,
  // pedersen,
} from "starknet";

export const Starknet = () => {
  const connectors = getInstalledInjectedConnectors();
  return (
    <StarknetProvider connectors={connectors}>
      <Connect />
      <AccountAddress />
      <GetBlock />
      <GetContract />
    </StarknetProvider>
  );
};

function GetContract() {
  invoke();
  return <div></div>;
}

async function invoke() {
  const account = new Contract(
    contractAbi,
    "0x00da114221cb83fa859dbdb4c44beeaa0bb37c7537ad5ae66fe5e0efd20e6eb3"
  );
  if (account === undefined) {
    return null;
  }

  // console.log(account);

  const res = await account.call("total_supply");
  // console.log(res);
}

function Connect() {
  const { connect, connectors } = useConnectors();
  return (
    <div>
      {connectors.map((connector) =>
        connector.available() ? (
          <button key={connector.id()} onClick={() => connect(connector)}>
            Connect {connector.name()}
          </button>
        ) : null
      )}
    </div>
  );
}

function GetBlock() {
  const { data, loading, error } = useStarknetBlock();
  console.log(loading);
  console.log(error);
  // let data_string = data;

  if (data === undefined) {
    return null;
  }
  return <div>Current block hash {data.block_hash}</div>;
}

function AccountAddress() {
  const { account } = useStarknet();

  return <div>Your account is {account}</div>;
}
