export const PlayButton = () => {
  const { account } = useStarknet();

  // const [contractContent, setContractContent] = useState();

  return (
    <button
      onClick={() => {
        Play(account);
      }}
    >
      Play
    </button>
  );
};
