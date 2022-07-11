import {
  // StarknetProvider,
  // useContract,
  // useStarknetBlock,
  // useStarknetCall,
  // useStarknetInvoke,
  // useStarknetTransactionManager,
  // Transaction,
  useStarknet,
  useConnectors,
  // getInstalledInjectedConnectors,
} from "@starknet-react/core";
import {
  Section,
  SectionTitle,
  ActionRoot,
  Button,
  SectionRoot,
  Wrapper,
} from "../general.styles";

export function ConnectButton() {
  const { connect, connectors } = useConnectors();
  return (
    <Wrapper>
      {connectors.map((connector) =>
        connector.available() ? (
          <Button key={connector.id()} onClick={() => connect(connector)}>
            Connect {connector.name()}
          </Button>
        ) : null
      )}
    </Wrapper>
  );
}
export function DemoAccount() {
  const { account } = useStarknet();
  const { connect, disconnect, connectors } = useConnectors();

  return (
    <SectionRoot>
      <Section>
        <SectionTitle>Account</SectionTitle>
        {account ? (
          <div>
            <p>Connected Account: {account}</p>
            <Button onClick={disconnect}>Disconnect</Button>
          </div>
        ) : (
          <div style={{ display: "flex", gap: "2rem" }}>
            {connectors.map((connector) =>
              connector.available() ? (
                <ActionRoot key={connector.id()}>
                  <Button
                    key={connector.id()}
                    onClick={() => connect(connector)}
                  >
                    Connect {connector.name()}
                  </Button>
                </ActionRoot>
              ) : null
            )}
          </div>
        )}
      </Section>
    </SectionRoot>
  );
}

// export function ConnectButton() {
//   const {
//     account,
//     connected,
//     setConnected,
//     connectBrowserWallet,
//     checkMissingWallet,
//   } = useStarknet();

//   useEffect(() => {
//     checkMissingWallet();
//   }, [checkMissingWallet]);

//   useEffect(() => {
//     if (account && account.length > 0) {
//       setConnected(true);
//     }
//   }, [account, setConnected, connected]);

//   return !connected ? (
//     <Button
//       ml="4"
//       textDecoration="none !important"
//       outline="none !important"
//       // boxShadow="none !important"
//       onClick={() => {
//         console.log("clicked");
//         connectBrowserWallet();
//       }}
//     >
//       Connect Wallet
//     </Button>
//   ) : (
//     <Button
//       ml="4"
//       textDecoration="none !important"
//       outline="none !important"
//       // boxShadow="none !important"
//       onClick={() => {
//         setConnected(false);
//       }}
//     >
//       {account
//         ? `${account.substring(0, 4)}...${account.substring(
//             account.length - 4
//           )}`
//         : "No Account"}
//     </Button>
//   );
// }
