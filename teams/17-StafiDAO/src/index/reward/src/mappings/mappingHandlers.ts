import { AssignReward } from "../types";
import { FrontierEvmEvent } from '@subql/contract-processors/dist/frontierEvm';
import { BigNumber } from "ethers";

// Setup types from ABI
type RewardEventArgs = [string, BigNumber] & {rewardAddrs: string[]; rewardAmounts: BigNumber[]; };

export async function handleRewardEvmEvent(event: FrontierEvmEvent<RewardEventArgs>): Promise<void> {

    for(let i = 0;i < event.args.rewardAddrs.length;i++) {
        let assignReward = new AssignReward(event.transactionHash + i);
        assignReward.transactionHash =  event.transactionHash;
        assignReward.recipient = event.args.rewardAddrs[i];
        assignReward.amount = event.args.rewardAmounts[i].toBigInt();
        assignReward.contractAddress = event.address;
        await assignReward.save();
    }

}

