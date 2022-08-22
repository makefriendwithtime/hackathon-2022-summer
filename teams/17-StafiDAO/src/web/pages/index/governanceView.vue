<template>
	<view class="">
		<view class="">
			技术方手续费:<text>{{daoTechFee}}</text>
		</view>
		<view class="">
			收集人服务费:<text>{{collatorTechFee}}</text>
		</view>
		<view class="">
			节点投资抵押最低下限:<text>{{fundsDownLimit}}</text>
		</view>
		<view class="">
			投资抵押上限:<text>{{fundsUpLimit}}</text>
		</view>
		<view class="">
			每人次投资抵押下限:<text>{{perInvestDownLimit}}</text>
		</view>
		<view class="">
			投票参与票数有效比例:<text>{{voterProportion}}</text>
		</view>
		<view class="">
			最低分配奖励额度:<text>{{rewardDownLimit}}</text>
		</view>
		<view class="">
			租赁收益和空投起始计算时限:<text>{{calTime}}</text>
		</view>
		<view class="">
			Pool准备金比例:<text>{{reserveProportion}}</text>
		</view>
		<view class="">
			Pool最低赎回时限:<text>{{redeemTimeLimit}}</text>
		</view>
		<view class="">
			收集人和委托人零受益时限:<text>{{zeroTimeLimit}}</text>
		</view>
		<view class="">
			收集人和委托人租赁保证金比例（retToken）:<text>{{marginProportion}}</text>
		</view>
		<view class="">
			发起提案最低数量:<text>{{proposalDownLimit}}</text>
		</view>
		<view class="">
			治理信息,根据提案编号:<text>{{governanceInfo}}</text>
		</view>
		<view class="">
			治理投票状态,根据提案编号和地址:<text>{{governanceVote}}</text>
		</view>

	</view>
</template>

<script>
	import {
		getDaoTechFee,
		getCollatorTechFee,
		getFundsDownLimit,
		getFundsUpLimit,
		getPerInvestDownLimit,
		getVoterProportion,
		getRewardDownLimit,
		getCalTime,
		getReserveProportion,
		getRedeemTimeLimit,
		getZeroTimeLimit,
		getMarginProportion,
		getProposalDownLimit,
		getGovernanceInfo,
		getGovernanceVote
	} from "@/methods/Governance.js"
	export default {
		data() {
			return {
				daoTechFee: "", //技术方手续费
				collatorTechFee: "", //收集人服务费
				fundsDownLimit: "", //节点投资抵押最低下限
				fundsUpLimit: "", //投资抵押上限
				perInvestDownLimit: "", //每人次投资抵押下限
				voterProportion: "", //投票参与票数有效比例
				rewardDownLimit: "", //最低分配奖励额度
				calTime: "", //租赁收益和空投起始计算时限
				reserveProportion: "", //Pool准备金比例
				redeemTimeLimit: "", //Pool最低赎回时限
				zeroTimeLimit: "", //收集人和委托人零受益时限
				marginProportion: "", //收集人和委托人租赁保证金比例（retToken）
				proposalDownLimit: "", //发起提案最低数量
				governanceInfo: "", //治理信息,根据提案编号
				governanceVote: "", //治理投票状态,根据提案编号和地址
			}
		},
		methods: {
			async getDaoTechFee() {//技术方手续费
				try {
					this.daoTechFee = await getDaoTechFee()
				} catch (e) {
					console.log(e)
				}
			},
			async getCollatorTechFee() {//收集人服务费
				try {
					this.collatorTechFee= await getCollatorTechFee()
				} catch (e) {
					console.log(e)
				}
			},
			async getFundsDownLimit() {//节点投资抵押最低下限
				try {
					this.fundsDownLimit = await getFundsDownLimit()
				} catch (e) {
					console.log(e)
				}
			},
			async getFundsUpLimit() {//投资抵押上限
				try {
					this.fundsUpLimit = await getFundsUpLimit()
				} catch (e) {
					console.log(e)
				}
			},
			async getPerInvestDownLimit() {//每人次投资抵押下限
				try {
					this.perInvestDownLimit = await getPerInvestDownLimit()
				} catch (e) {
					console.log(e)
				}
			},
			async getVoterProportion() {//投票参与票数有效比例
				try {
					this.voterProportion = await getVoterProportion()
				} catch (e) {
					console.log(e)
				}
			},
			async getRewardDownLimit() {//最低分配奖励额度
				try {
					this.rewardDownLimit = await getRewardDownLimit()
				} catch (e) {
					console.log(e)
				}
			},
			async getCalTime() {//租赁收益和空投起始计算时限
				try {
					this.calTime = await getCalTime()
				} catch (e) {
					console.log(e)
				}
			},
			async getReserveProportion() {//Pool准备金比例
				try {
					this.reserveProportion = await getReserveProportion()
				} catch (e) {
					console.log(e)
				}
			},
			async getRedeemTimeLimit() {//Pool最低赎回时限
				try {
					this.redeemTimeLimit = await getRedeemTimeLimit()
				} catch (e) {
					console.log(e)
				}
			},
			async getZeroTimeLimit() {//收集人和委托人零受益时限
				try {
					this.zeroTimeLimit = await getZeroTimeLimit()
				} catch (e) {
					console.log(e)
				}
			},
			async getMarginProportion() {//收集人和委托人租赁保证金比例（retToken）
				try {
					this.marginProportion = await getMarginProportion()
				} catch (e) {
					console.log(e)
				}
			},
			async getProposalDownLimit() {//发起提案最低数量
				try {
					this.proposalDownLimit = await getProposalDownLimit()
				} catch (e) {
					console.log(e)
				}
			},
			async getGovernanceInfo() {//治理信息,根据提案编号
				try {
					this.governanceInfo = await getGovernanceInfo()
				} catch (e) {
					console.log(e)
				}
			},
			async getGovernanceVote() {//治理投票状态,根据提案编号和地址
				try {
					this.governanceVote = await getGovernanceVote()
				} catch (e) {
					console.log(e)
				}
			}
			
		},
		onLoad() {
			Promise.all([
				this.getDaoTechFee(),//技术方手续费
				this.getCollatorTechFee(),//收集人服务费
				this.getFundsDownLimit(),//节点投资抵押最低下限
				this.getFundsUpLimit(),//投资抵押上限
				this.getPerInvestDownLimit(),//每人次投资抵押下限
				this.getVoterProportion(),//投票参与票数有效比例
				this.getRewardDownLimit(),//最低分配奖励额度
				this.getCalTime(),//租赁收益和空投起始计算时限
				this.getReserveProportion(),//Pool准备金比例
				this.getRedeemTimeLimit(),//Pool最低赎回时限
				this.getZeroTimeLimit(),//收集人和委托人零受益时限
				this.getMarginProportion(),//收集人和委托人租赁保证金比例（retToken）
				this.getProposalDownLimit(),//发起提案最低数量
				this.getGovernanceInfo(),//治理信息,根据提案编号
				this.getGovernanceVote()//治理投票状态,根据提案编号和地址
			])
		}
	}
</script>

<style>
</style>
