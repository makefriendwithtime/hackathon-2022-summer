<template>
	<view class="">
		<view class="planToRedeem" >
			计划赎回
		</view>
		<view class="redeem" @click="mmshow=true">
			赎回
		</view>
		<u-popup :show="mmshow" @close="mmshow = false" :round="10">
		  <view class="mms-main">
		    <text>- 请输入Stake数量 -</text>
		    <input type="number" placeholder="请输入赎回数量" v-model.trim="amount" />
		    <view class="mint-btn" @click="redeemStake">立即Stake</view>
		  </view>
		</u-popup>
	</view>
</template>

<script>
	import {
		redeemStake
	} from "@/methods/Pool.js";
	export default{
		data(){
			return{
				amount:"",
				mmshow:false
			}
		},
		methods:{
			async redeemStake(){//计划赎回
			    if(!this.amount){
					this.$u.toast("请输入你想赎回的数量！");
					return
				}else{
					let res=await redeemStake(this.amount)
					res &&this.$u.toast("交易成功！");
				} 
			},
			async getRedeem() {//查看赎回
				let res= await getRedeem();
				console.log(res)
			},
			// async redeemStake(){
			// 	let res= await redeemStake();
			// 	console.log(res)
			// },
		},
		onLoad() {
		}
	}
</script>

<style lang="scss" scoped>
	.planToRedeem,.redeem{
		width: 70%;
		height: 80rpx;
		text-align: center;
		margin: 40rpx auto;
		color: #fff;
		line-height: 80rpx;
	}
	.planToRedeem{
		background-color: #0074D9;
	}
	.redeem{
		background-color: #000088;
	}
	.mms-main {
	  width: 90%;
	  height: auto;
	  overflow: hidden;
	  padding: 8% 5%;
	  text-align: center;
	}
	
	.mms-main text {
	  display: block;
	  font-size: 14px;
	  color: #999;
	}
	
	.mms-main input {
	  width: 60%;
	  height: auto;
	  overflow: hidden;
	  background: #eee;
	  padding: 10px 0;
	  text-align: center;
	  border-radius: 5px;
	  margin: 20px auto;
	}
	
	.mint-btn {
	  width: 100%;
	  height: auto;
	  overflow: hidden;
	  background: #333;
	  color: #fff;
	  border-radius: 10px;
	  padding: 12px 0;
	}
</style>
