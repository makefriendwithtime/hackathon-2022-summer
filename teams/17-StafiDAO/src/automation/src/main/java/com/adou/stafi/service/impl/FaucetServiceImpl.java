package com.adou.stafi.service.impl;

import com.adou.stafi.contract.Faucet;
import com.adou.stafi.service.IFaucetService;
import com.adou.stafi.utils.IConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tx.gas.DefaultGasProvider;

@Service
public class FaucetServiceImpl implements IFaucetService {

    @Autowired
    Web3j web3j;
    private static final Logger logger = LoggerFactory.getLogger(FaucetServiceImpl.class);

    @Override
    public Boolean executeRedeemStake(String faucetAddr) {
        Boolean result = false;
        try {
            Faucet faucet = Faucet.load(faucetAddr, web3j,
                    Credentials.create(IConfig.get("privateKey")), new DefaultGasProvider());
            TransactionReceipt receipt = faucet.executeRedeemStake().sendAsync().get();
            if ("0x1".equals(receipt.getStatus())) {
                result = true;
                logger.info("确认已计划回收的选票，并返还到质押池Pool成功！" + receipt.toString(), receipt);
            } else {
                logger.warn("确认已计划回收的选票，并返还到质押池Pool失败！" + receipt.toString(), receipt);
            }
        } catch (Exception e) {
            logger.error("确认已计划回收的选票，并返还到质押池Pool报错！" + e.getMessage(), e);
        }
        return result;
    }

    @Override
    public void scheduleRedeemStake(String faucetAddr) {
        try {
            Faucet faucet = Faucet.load(faucetAddr, web3j,
                    Credentials.create(IConfig.get("privateKey")), new DefaultGasProvider());
            TransactionReceipt receipt = faucet.scheduleRedeemStake().sendAsync().get();
            if ("0x1".equals(receipt.getStatus())) {
                logger.info("按选票信息正常计划回收选票成功！" + receipt.toString(), receipt);
            } else {
                logger.warn("按选票信息正常计划回收选票失败！" + receipt.toString(), receipt);
            }
        } catch (Exception e) {
            logger.error("按选票信息正常计划回收选票报错！" + e.getMessage(), e);
        }
    }

    @Override
    public void zeroIncomePunish(String faucetAddr) {
        try {
            Faucet faucet = Faucet.load(faucetAddr, web3j,
                    Credentials.create(IConfig.get("privateKey")), new DefaultGasProvider());
            TransactionReceipt receipt = faucet.zeroIncomePunish().sendAsync().get();
            if ("0x1".equals(receipt.getStatus())) {
                logger.info("零收益处罚，并强制计划回收选票成功！" + receipt.toString(), receipt);
            } else {
                logger.warn("零收益处罚，并强制计划回收选票失败！" + receipt.toString(), receipt);
            }
        } catch (Exception e) {
            logger.error("零收益处罚，并强制计划回收选票报错！" + e.getMessage(), e);
        }
    }

    @Override
    public void sendReward(String faucetAddr) {
        try {
            Faucet faucet = Faucet.load(faucetAddr, web3j,
                    Credentials.create(IConfig.get("privateKey")), new DefaultGasProvider());
            TransactionReceipt receipt = faucet.sendReward().sendAsync().get();
            if ("0x1".equals(receipt.getStatus())) {
                logger.info("抵押收益，发送到奖励池成功！" + receipt.toString(), receipt);
            } else {
                logger.warn("抵押收益，发送到奖励池失败！" + receipt.toString(), receipt);
            }
        } catch (Exception e) {
            logger.error("抵押收益，发送到奖励池报错！" + e.getMessage(), e);
        }
    }

    public static void main(String[] args) {
    }
}
