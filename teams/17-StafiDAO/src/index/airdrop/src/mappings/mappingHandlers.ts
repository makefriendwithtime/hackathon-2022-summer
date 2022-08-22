import { Droping } from "../types";
import { FrontierEvmEvent } from '@subql/contract-processors/dist/frontierEvm';

import { BigNumber } from "ethers";

// Setup types from ABI
type DropingEventArgs = [string, BigNumber] & { dropAddrs: string[]; dropAmounts: BigNumber[]; };

export async function handleAirdropEvmEvent(event: FrontierEvmEvent<DropingEventArgs>): Promise<void> {

    for(let i = 0;i < event.args.dropAddrs.length;i++) {
        const droping = new Droping(event.transactionHash + i);
        droping.transactionHash = event.transactionHash;
        droping.value = event.args.dropAmounts[i].toBigInt();
        droping.from = '0x0000000000000000000000000000000000000000';
        droping.to = event.args.dropAddrs[i];
        droping.contractAddress = event.address;
        await droping.save();
    }

}