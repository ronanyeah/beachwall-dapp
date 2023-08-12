const { Elm } = require("./Main.elm");

import { Adapter } from "@solana/wallet-adapter-base";
import { SolanaConnect } from "solana-connect";
import {
  TransactionInstruction,
  TransactionMessage,
  VersionedTransaction,
  PublicKey,
  Connection,
  SystemProgram,
} from "@solana/web3.js";
import { BN } from "bn.js";
import { Squares } from "./codegen/accounts/Squares";
import { edit } from "./codegen/instructions/edit";
import { PROGRAM_ID } from "./codegen/programId";
import { ElmApp } from "./ports";

const connection = new Connection(
  "https://solana-mainnet.rpc.extrnode.com"
  //{ wsEndpoint: "wss://solana-mainnet.rpc.extrnode.com" }
);

// eslint-disable-next-line fp/no-let
let activeWallet: null | Adapter = null;

const solConnect = new SolanaConnect();

(async () => {
  const [canvasAddr] = await PublicKey.findProgramAddress(
    [Buffer.from("canvas1")],
    PROGRAM_ID
  );

  const data = await Squares.fetch(connection, canvasAddr);

  connection.onAccountChange(
    canvasAddr,
    (updatedAccountInfo) => {
      try {
        app.ports.squareChange.send(
          Squares.decode(updatedAccountInfo.data).squares
        );
      } catch (e) {
        console.error(e);
      }
    },
    "confirmed"
  );

  const app: ElmApp = Elm.Main.init({
    node: document.getElementById("app"),
    flags: {
      sqs: data?.squares,
      //sqs: Array.from(new Array(1600)).map(() => [255, 255, 255]),
      screen: { width: window.innerWidth, height: window.innerHeight },
      wallet: null,
    },
  });

  solConnect.onWalletChange((wallet) => {
    if (wallet && wallet.publicKey) {
      // eslint-disable-next-line fp/no-mutation
      activeWallet = wallet;
      app.ports.connectResponse.send(wallet.publicKey.toString());
    } else {
      app.ports.disconnect.send(null);
    }
  });

  app.ports.connect.subscribe(async () => {
    solConnect.openMenu();
  });

  app.ports.edit.subscribe(({ n, col }) =>
    (async () => {
      if (!(activeWallet && activeWallet.publicKey)) {
        alert("Invalid wallet connection!");
        return app.ports.editResponse.send(false);
      }

      const accounts = {
        payer: activeWallet.publicKey,
        squares: canvasAddr,
        systemProgram: SystemProgram.programId,
      };

      const ix = edit({ index: new BN(n), value: col }, accounts);

      const sig = await launch(activeWallet, [ix]);
      console.log(sig);

      app.ports.editResponse.send(true);
    })().catch((err) => {
      console.error(err.logs ? [err.logs, err] : err);
      app.ports.editResponse.send(false);
    })
  );
})().catch(console.error);

const launch = async (
  wallet: Adapter,
  ixs: TransactionInstruction[]
): Promise<string> => {
  if (!wallet.publicKey) {
    throw Error("missing pubkey");
  }

  const latestBlockHash = await connection.getLatestBlockhash();
  const messageV0 = new TransactionMessage({
    payerKey: wallet.publicKey,
    recentBlockhash: latestBlockHash.blockhash,
    instructions: ixs,
  }).compileToV0Message();
  const tx = new VersionedTransaction(messageV0);

  return wallet.sendTransaction(tx, connection);
};
