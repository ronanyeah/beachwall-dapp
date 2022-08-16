import { PublicKey, Connection } from "@solana/web3.js"
import BN from "bn.js" // eslint-disable-line @typescript-eslint/no-unused-vars
import * as borsh from "@project-serum/borsh" // eslint-disable-line @typescript-eslint/no-unused-vars
import { PROGRAM_ID } from "../programId"

export interface SquaresFields {
  squares: Array<Array<number>>
}

export interface SquaresJSON {
  squares: Array<Array<number>>
}

export class Squares {
  readonly squares: Array<Array<number>>

  static readonly discriminator = Buffer.from([
    73, 65, 94, 212, 203, 87, 115, 100,
  ])

  static readonly layout = borsh.struct([
    borsh.vec(borsh.array(borsh.u8(), 3), "squares"),
  ])

  constructor(fields: SquaresFields) {
    this.squares = fields.squares
  }

  static async fetch(
    c: Connection,
    address: PublicKey
  ): Promise<Squares | null> {
    const info = await c.getAccountInfo(address)

    if (info === null) {
      return null
    }
    if (!info.owner.equals(PROGRAM_ID)) {
      throw new Error("account doesn't belong to this program")
    }

    return this.decode(info.data)
  }

  static async fetchMultiple(
    c: Connection,
    addresses: PublicKey[]
  ): Promise<Array<Squares | null>> {
    const infos = await c.getMultipleAccountsInfo(addresses)

    return infos.map((info) => {
      if (info === null) {
        return null
      }
      if (!info.owner.equals(PROGRAM_ID)) {
        throw new Error("account doesn't belong to this program")
      }

      return this.decode(info.data)
    })
  }

  static decode(data: Buffer): Squares {
    if (!data.slice(0, 8).equals(Squares.discriminator)) {
      throw new Error("invalid account discriminator")
    }

    const dec = Squares.layout.decode(data.slice(8))

    return new Squares({
      squares: dec.squares,
    })
  }

  toJSON(): SquaresJSON {
    return {
      squares: this.squares,
    }
  }

  static fromJSON(obj: SquaresJSON): Squares {
    return new Squares({
      squares: obj.squares,
    })
  }
}
