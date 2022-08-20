const { Elm } = require("./Main.elm");

import { BaseSignerWalletAdapter } from "@solana/wallet-adapter-base";
import {
  PhantomWalletAdapter,
  SolflareWalletAdapter,
  GlowWalletAdapter,
  LedgerWalletAdapter,
} from "@solana/wallet-adapter-wallets";
import { web3 } from "@project-serum/anchor";
import { BN } from "bn.js";
import { Squares } from "./codegen/accounts/Squares";
import { edit } from "./codegen/instructions/edit";
import { PROGRAM_ID } from "./codegen/programId";

const connection = new web3.Connection("https://ssc-dao.genesysgo.net/");

// eslint-disable-next-line fp/no-let
let activeWallet: null | BaseSignerWalletAdapter = null;

const getWallet = (n: number) => {
  const wallet = (() => {
    switch (n) {
      case 0: {
        return new PhantomWalletAdapter();
      }
      case 1: {
        return new SolflareWalletAdapter();
      }
      case 2: {
        return new GlowWalletAdapter();
      }
      default: {
        return new LedgerWalletAdapter();
      }
    }
  })();

  return wallet.readyState === "Installed" || wallet.readyState === "Loadable"
    ? wallet
    : null;
};

(async () => {
  const [canvasAddr] = await web3.PublicKey.findProgramAddress(
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

  const app = Elm.Main.init({
    node: document.getElementById("app"),
    flags: {
      sqs: data?.squares,
      screen: { width: window.innerWidth, height: window.innerHeight },
    },
  });

  app.ports.disconnect.subscribe(() => {
    // eslint-disable-next-line fp/no-mutation
    activeWallet = null;
  });

  app.ports.connect.subscribe(async (id: number) => {
    const wallet = getWallet(id);

    if (!wallet) {
      return alert("Not available!");
    }

    await wallet.connect();

    if (!wallet.connected) {
      console.log("reconnect");
      await wallet.connect();
    }

    if (!wallet.publicKey) {
      return alert("Invalid wallet connection!");
    }

    // eslint-disable-next-line fp/no-mutation
    activeWallet = wallet;

    app.ports.connectResponse.send(wallet.publicKey.toString());
  });

  app.ports.edit.subscribe(({ n, col }: { n: number; col: [number] }) =>
    (async () => {
      if (!(activeWallet && activeWallet.connected && activeWallet.publicKey)) {
        alert("Invalid wallet connection!");
        return app.ports.editResponse.send(false);
      }

      const accounts = {
        payer: activeWallet.publicKey,
        squares: canvasAddr,
        systemProgram: web3.SystemProgram.programId,
      };

      const transaction = new web3.Transaction();

      const ix = edit({ index: new BN(n), value: col }, accounts);
      transaction.add(ix);

      const sig = await launch(activeWallet, transaction);

      console.log(sig);

      app.ports.editResponse.send(true);
    })().catch((err) => {
      console.error(err.logs ? [err.logs, err] : err);
      app.ports.editResponse.send(false);
    })
  );
})();

const launch = async (
  wallet: BaseSignerWalletAdapter,
  transaction: web3.Transaction
) => {
  const { blockhash } = await connection.getRecentBlockhash();

  /* eslint-disable fp/no-mutation */
  transaction.recentBlockhash = blockhash;
  if (wallet.publicKey) {
    transaction.feePayer = wallet.publicKey;
  }
  /* eslint-enable fp/no-mutation */

  const signedTransaction = await wallet.signTransaction(transaction);

  return connection.sendRawTransaction(signedTransaction.serialize());
};
