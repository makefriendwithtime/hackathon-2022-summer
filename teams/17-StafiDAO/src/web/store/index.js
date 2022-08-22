import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

export default new Vuex.Store({
	state: {
		contractAddress: "0x60F2375e985C819c809B53d36eba3C4f83c22415", //合约地址
		//、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、、

		accs: "", //第一位账户
		pool: "0x95BB2F96C6585f08BA4D65854C04A2e355d0853A",
		reward: "0xC92Eb0Fe7D49B1A7886af4e35BFa87237F21B38A",
		airdrop: "0xDd4aa74455f4E0861e5561EC3CDBF7b05C69f588",
		governance: "0xab38951163FF96A414AAC69D5B4365DB6EC560da",
		faucet: "0xCAe4C3c92FBFC119B7eC70203D629369654D9BF6",
		factory: "0x628974B59e095dDecB25d4D012C8405bF3c0a87f",

		/////////////////////////////////////////////////////////////////////////

		factoryAddress: "", //创建DAO合约地址  调合约最后使用此地址
		poolAddress: "0x27a9CCa294c7f68238307ceA2853B9b96Aeb3bF5", //水龙头合约地址      调合约最后使用此地址
		rewardAddress: "0x11f5E709Fd3cA37cdBbAC456702008E67de4b3Ca", //奖励池合约地址    调合约最后使用此地址
		airdropAddress: "0x86Ae94DF1d3d0DeE8cc7440Ed9ADe6272020AfA9", //空投合约地址     调合约最后使用此地址
		governanceAddress: "0xdea83550A365cadAd3808fF95316F4c572E3f835", //治理合约地址  调合约最后使用此地址
		faucetAddress: "", //水龙头合约地址    调合约最后使用此地址
	},
	mutations: {
		updateAccs(state, val) {
			//accs赋值
			state.accs = val;
			console.log(val);
		},
		setGovernan(state, val) {
			state.governanceAddress = val;
		},
		setPool(state, val) {
			state.poolAddress = val;
		},
		setAirdrop(state, val) {
			state.airdropAddress = val;
		},
		setReward(state, val) {
			state.rewardAddress = val;
		},

	},
	actions: {},
	getters: {},
});
