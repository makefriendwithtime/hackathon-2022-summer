<template>
	<view class="">
		_authorAmount:<input type="text" value="" v-model="params.authorAmount" />
		<!-- fundsDownLimit; -->
		_blockHeight:<input type="text" value="" v-model="params.blockHeight" />
		<!-- perInvestDownLimit; -->
		_stkName:<input type="text" value="" v-model="params.stkName" />
		<!-- nodeStartDate -->
		_stkSymbol:<input type="text" value="" v-model="params.stkSymbol" />
		<!-- rewardDownLimit; -->
		_retName:<input type="text" value="" v-model="params.retName" />
		<!-- _techRewardAddr -->
		_retSymbol:<input type="text" value="" v-model="params.retSymbol" />
		<!-- scheduleTime -->
		_retAmount<input type="text" value="" v-model="params.retAmount" />
		<view class="btn" @click="sudoSubmit">
			确定
		</view>
		<!-- <view class="btn" @click="start">
			DAO开启
		</view> -->
		<view class="">
			获取收集人地址集:<text>{{delegatorAddrs}}</text>
		</view>
		<view class="">
			获取委托人地址集:<text>{{collatorAddrs}}</text>
		</view>
	</view>
</template>

<script>
	import {
		createDAO,
		
	} from "@/methods/Factory.js";
	import {
		getDelegatorAddrs,
		getCollatorAddrs
	} from "@/methods/Pool.js"
	export default {
		data() {
			return {
				params: {
					delegatorAddrs:"",//获取收集人地址集
					collatorAddrs:"",//获取委托人地址集
					authorAmount: "",
					blockHeight: "",
					stkName: "",
					stkSymbol: "",
					retName: "",
					retSymbol: "",
					retAmount: "",
				}
			}
		},
		methods: {
			async sudoSubmit(){
				try{
					let res=await createDAO(this.params)
				}catch (e) {
					console.log(e)
				}
			},
			async getDelegatorAddrs() {//获取收集人地址集
				try {
					this.delegatorAddrs = await getDelegatorAddrs()
				} catch (e) {
					console.log(e)
				}
			},
			async getCollatorAddrs() {//获取委托人地址集
				try {
					this.collatorAddrs = await getCollatorAddrs()
				} catch (e) {
					console.log(e)
				}
			}
		},
		onLoad() {
			Promise.all([
				this.getDelegatorAddrs(),//获取收集人地址集
				this.getCollatorAddrs(),//获取委托人地址集
			])
		}
	}
</script>

<style>
	input {
		background-color: #007AFF
	}

	.btn {
		width: 70%;
		height: 80rpx;
		margin: 30rpx auto;
		background-color: #8EE0F6;
		color: #fff;
		text-align: center;
		line-height: 80rpx;
	}
</style>
