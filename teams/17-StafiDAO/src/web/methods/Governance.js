import Web3 from "./web3.min.js";
import $store from "@/store/index";
import Web3_, {
	providers
} from "web3";
import governance from "../contracts/Governance.json";
let web3;
let web3_ = new Web3(
	new providers.HttpProvider("https://rpc.testnet.moonbeam.network")
);
let myContract = new web3_.eth.Contract(governance.abi, $store.state.governanceAddress);

function web3_new() {
	if (window.ethereum) {
		try {
			window.ethereum.enable();
		} catch (error) {
			console.error("User denied account access");
		}
		web3 = new Web3(window.ethereum);
	} else if (window.web3) {
		web3 = new Web3(window.ethereum);
	} else {
		alert("Please install wallet");
	}
	const contract = new web3.eth.Contract(
		governance.abi,
		$store.state.governanceAddress
	);
	return contract
}

export async function getDaoTechFee() {
   //技术方手续费
  let res = await myContract.methods.getDaoTechFee().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getCollatorTechFee() {
   //收集人服务费
  let res = await myContract.methods.getCollatorTechFee().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getFundsDownLimit() {
   //节点投资抵押最低下限
  let res = await myContract.methods.getFundsDownLimit().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getFundsUpLimit() {
   //投资抵押上限
  let res = await myContract.methods.getFundsUpLimit().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getPerInvestDownLimit() {
   //每人次投资抵押下限
  let res = await myContract.methods.getPerInvestDownLimit().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getVoterProportion() {
   //查看投票参与票数有效比例
  let res = await myContract.methods.getVoterProportion().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getRewardDownLimit() {
   //查看最低分配奖励额度
  let res = await myContract.methods.getRewardDownLimit().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getCalTime() {
   //查看租赁收益和空投起始计算时限
  let res = await myContract.methods.getCalTime().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getReserveProportion() {
   //查看Pool准备金比例
  let res = await myContract.methods.getReserveProportion().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getRedeemTimeLimit() {
   //查看Pool最低赎回时限
  let res = await myContract.methods.getRedeemTimeLimit().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getZeroTimeLimit() {
   //查看收集人和委托人零受益时限
  let res = await myContract.methods.getZeroTimeLimit().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getMarginProportion() {
   //查看收集人和委托人租赁保证金比例（retToken）
  let res = await myContract.methods.getMarginProportion().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getProposalDownLimit() {
   //查看发起提案最低数量
  let res = await myContract.methods.getProposalDownLimit().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getGovernanceInfo() {
   //查看治理信息,根据提案编号
  let res = await myContract.methods.getGovernanceInfo().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}

export async function getGovernanceVote() {
   //查看治理投票状态,根据提案编号和地址
  let res = await myContract.methods.getGovernanceVote().call({
    from: $store.state.accs,
    gas: 3141592,
  });
  return res;
}


