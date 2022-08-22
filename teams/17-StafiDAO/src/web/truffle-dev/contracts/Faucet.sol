// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "./StakingInterface.sol";
import "./AuthorMappingInterface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IAirdrop{
    function zeroIncomePunish(uint _leaseDate,uint256 _amount) external;
    function unlockLeaseMargin(
        address _account,
        uint _leaseDate,
        uint256 _amount
    ) external;
}

interface IGovernance{
    function getRewardDownLimit() external  view returns(uint);
    function getZeroTimeLimit() external  view returns(uint); 
    function stkTokenAddr() external view returns (address);
    function retTokenAddr() external view returns (address);
    function rewardAddr() external view returns (address);
    function authorAmount() external view returns(uint256);
    function blockHeight() external  view returns(uint);
    function getCollatorTechFee() external  view returns(uint);
    function getDaoTechFee() external  view returns(uint);
    function ownerAddress() external view returns (address);
}

contract Faucet{
    using SafeMath for uint256;

    IGovernance public Igovern;
    IAirdrop public Iairdrop;
    
    //水龙头类型
    bool public faucetType;//真收集人，假为委托人
    //委托收集人地址(faucetType为假有效)
    address public collatorAddr;
    //收集人技术服务奖励地址
    address public techAddr;
    //租赁日期数组，按序号排
    mapping(uint => uint) public leaseDates;
    //总的租赁数
    uint256 public leaseTotal = 0;
    //租赁状态
    bool public bstate = false;
    //退出租赁时所在区块高度
    uint256 public leaveNumber = 0;
    //绑定的nimbusId
    bytes32 public nimbusId;
    //association激活标记
    bool public associationFlag = false;
    //每peroid包含的天数
    uint public constant dayLen = 30;
    
    //数组序号
    uint private len = 0;
    //租赁信息
    struct LeaseInfo{
        uint period;//租赁周期:1个周期为30天，2个周期为60天，依次类推
        uint256 amount;//租赁票数
        uint256 marginAmount;//抵押票数
        uint256 number;//正常赎回区块高度
        address reddeemAddr;//抵押赎回地址
        bool bflag;//是否有效
    }
    mapping(uint => LeaseInfo) public leaseInfos;
    //预编译地址
    address private constant precompileAddress = 0x0000000000000000000000000000000000000800;
    address private constant precompileAuthorMappingAddr = 0x0000000000000000000000000000000000000807;
    //预编译接口对象
    ParachainStaking private staking;
    AuthorMapping private authorMapping;
    //无奖励计数
    uint punishCount = 0;
    //奖励记录信息(每日一次)
    struct DayRewardInfo{
        uint rdDate;//最新奖励日期
        uint256 rdamount;//最新奖励账户余额
    }
    DayRewardInfo public dayRewardInfo;
    //委托人/收集人管理者
    address public owner;
    //lock锁
    bool private unlocked = true;

    constructor (){
    }

    //克隆合约初始化调用
    function initialize (
        address _governAddr,
        address _collatorAddr,
        address _techAddr,
        address _owner,
        bool _faucetType
    ) external{
        require(address(Igovern) == address(0),'Igovern seted!');
        Igovern = IGovernance(_governAddr);
        staking = ParachainStaking(precompileAddress);
        owner = _owner;
        faucetType = _faucetType;
        if(faucetType){
            techAddr = _techAddr;
            authorMapping = AuthorMapping(precompileAuthorMappingAddr);
        }else{
            collatorAddr = _collatorAddr;
        }
        //克隆合约需要初始化非默认值非constant的参数值
        unlocked = true;
    }

    fallback () external payable{}

    receive () external payable{
        //判断发送地址是否来自Pool，来自Pool则调用激活委托人或为委托人增加选票
        if(Igovern.stkTokenAddr() == msg.sender){
            if(bstate){
                //增加收集人/委托人选票
                ActivateFaucet();
            }else{
                //激活收集人/委托人
                updateFaucet();
            }
        }
    }

    modifier isOwner() { 
        require(msg.sender == owner,'Not management!');
        _;
    }

    modifier lock() {
        require(unlocked, 'Faucet: LOCKED!');
        unlocked = false;
        _;
        unlocked = true;
    }

    //激活收集人/委托人
    function ActivateFaucet() private {
        uint leaseDate = block.timestamp.div(24 * 60 * 60); 
        LeaseInfo memory info = leaseInfos[leaseDate];
        require(info.bflag && info.amount > 0 && address(this).balance >= info.amount,'ActivateDelegator: info is illegal!');
        //开始抵押
        if(faucetType){
            staking.join_candidates(info.amount, staking.candidate_count());
        }else{
            staking.delegate(collatorAddr, info.amount, staking.candidate_delegation_count(collatorAddr), staking.delegator_delegation_count(address(this)));
        }
        leaseTotal += info.amount;
        bstate = true;
    }

    //增加选票
    function updateFaucet() private {
        require(bstate,'updateDelegator: not delegator or collator!');
        uint leaseDate = block.timestamp.div(24 * 60 * 60); 
        LeaseInfo memory info = leaseInfos[leaseDate];
        require(info.bflag && info.amount > 0 && address(this).balance >= info.amount,'updateDelegator: info is illegal!');
        //开始抵押
        if(faucetType){
            staking.candidate_bond_more(info.amount);
        }else{
            staking.delegator_bond_more(collatorAddr, info.amount);
        }
        leaseTotal += info.amount;
    }

    //按地址日期租赁时限记录选票信息,_amount、_marginAmount单位为Wei
    function setLeaseInfo(
        address _reddeemAddr,
        uint _leaseDate,
        uint _period,
        uint256 _amount,
        uint256 _marginAmount
    ) public{
        require(_period > 0,'setLeaseInfo: period is illegal!');
        require(Igovern.stkTokenAddr() == msg.sender,'setLeaseInfo: msg.sender is illegal!');//保证从Pool发起
        LeaseInfo memory info = leaseInfos[_leaseDate];
        if(info.period == 0){
            leaseDates[len] = _leaseDate;
            len += 1;
        }
        if(info.bflag){
            info.amount = info.amount.add(_amount);
            info.marginAmount = info.marginAmount.add(_marginAmount);
        }else{
            info.amount = _amount;
            info.marginAmount = _marginAmount;
            info.bflag = true;
        }
        info.period = _period;
        info.number = 0;
        info.reddeemAddr = _reddeemAddr;
        leaseInfos[_leaseDate] = info; 
    }

    //抵押收益，发送到奖励池（定时器执行）
    function sendReward() public{
        require(associationFlag,'sendReward: not bind Association!');
        require(address(this).balance >= Igovern.getRewardDownLimit(),'sendReward: balance is not enough!');
        uint256 daoFee = address(this).balance.mul(Igovern.getDaoTechFee()).div(100);
        Address.sendValue(payable(Igovern.ownerAddress()), daoFee);
        if(faucetType){
            //奖励收集人
            uint256 techFee = address(this).balance.mul(Igovern.getCollatorTechFee()).div(100);
            Address.sendValue(payable(techAddr), techFee);
            Address.sendValue(payable(Igovern.rewardAddr()), address(this).balance.sub(techFee).sub(daoFee));
        }else{
            Address.sendValue(payable(Igovern.rewardAddr()), address(this).balance.sub(daoFee));
        }
    }

    //每日记录一次奖励信息（定时器执行）
    function recordRewardInfo() public{
        require(bstate,'recordRewardInfo: not delegator or collator!');
        uint rdDate = block.timestamp.div(24 * 60 * 60); 
        require(dayRewardInfo.rdDate < rdDate,'recordRewardInfo: rdDate is illegal!');
        if(dayRewardInfo.rdamount == address(this).balance){
            punishCount += rdDate.sub(dayRewardInfo.rdDate);
        }
        dayRewardInfo.rdDate = rdDate;
        dayRewardInfo.rdamount = address(this).balance;
    }

    //零收益处罚，并强制计划回收选票（定时器执行）
    function zeroIncomePunish() public lock{
        require(bstate,'zeroIncomePunish: not delegator  or collator!');
        require(punishCount >= Igovern.getZeroTimeLimit(),'zeroIncomePunish: punishCount is not enough!');
        Iairdrop = IAirdrop(Igovern.retTokenAddr());
        for(uint i = 0;i < len; i++){
            uint leaseDate = leaseDates[i];
            LeaseInfo memory info = leaseInfos[leaseDate];
            if(info.bflag){
                info.bflag = false;
                Iairdrop.zeroIncomePunish(leaseDate,info.marginAmount);
            }
        }
        //强制计划回收
        bstate = false;
        leaveNumber = block.number;
        if(faucetType){
            staking.schedule_leave_candidates(staking.candidate_count());
        }else{
            staking.schedule_leave_delegators();
        }        
    }

    //按选票信息正常计划回收选票（定时器执行）
    function scheduleRedeemStake() public lock{
        require(bstate,'not delegator or collator!');
        //赎回抵押
        for(uint i = 0;i < len; i++){
            uint leaseDate = leaseDates[i];
            LeaseInfo memory info = leaseInfos[leaseDate];
            if(info.bflag && leaseDate.add(info.period * dayLen) <= block.timestamp.div(24 * 60 * 60)){
                //根据数量判断是否委托退出或是部分赎回
                if(leaseTotal.sub(info.amount) < staking.min_delegation()){
                    bstate = false;
                    leaveNumber = block.number;
                    if(faucetType){
                        staking.schedule_leave_candidates(staking.candidate_count());
                    }else{
                        staking.schedule_leave_delegators();
                    }
                }else{
                    info.number = block.number;
                    if(faucetType){
                        staking.schedule_candidate_bond_less(info.amount);
                    }else{
                        staking.schedule_delegator_bond_less(collatorAddr, info.amount);
                    }                        
                }
                break;
            }
        }
    }
    //确认已计划回收的选票，并返还到质押池Pool（定时器执行）
    function executeRedeemStake() public lock{
        if(leaveNumber > 0){
            //判断区块高度是否到达设定高度
            require(leaveNumber.add(Igovern.blockHeight()) <= block.number,'not yet reached!');
            if(faucetType){
                //这里需要判断是否计划是否已经被执行，预编译文件等待更新接口

                staking.execute_leave_candidates(address(this),staking.candidate_delegation_count(address(this)));
                associationFlag = false;
                leaveNumber = block.number;
                authorMapping.clear_association(nimbusId);
            }else{
                leaveNumber = 0;
                //这里需要判断是否计划是否已经被执行
                if(staking.delegation_request_is_pending(address(this), collatorAddr)){
                    staking.execute_leave_delegators(address(this),staking.delegator_delegation_count(address(this)));
                }                
            }
            Address.sendValue(payable(Igovern.stkTokenAddr()), leaseTotal);
            Address.sendValue(payable(Igovern.rewardAddr()), address(this).balance.sub(leaseTotal));
            for(uint i = 0;i < len; i++){
                uint leaseDate = leaseDates[i];
                LeaseInfo memory info = leaseInfos[leaseDate];
                if(info.bflag){
                    info.bflag = false;
                    Iairdrop.unlockLeaseMargin(info.reddeemAddr,leaseDate,info.marginAmount);
                }
            }
        }else{
            for(uint i = 0;i < len; i++){
                uint leaseDate = leaseDates[i];
                LeaseInfo memory info = leaseInfos[leaseDate];
                if(info.bflag && info.number >0){
                    info.bflag = false;
                    //判断区块高度是否到达设定高度
                    require(info.number.add(Igovern.blockHeight()) <= block.number,'not yet reached!');
                    if(faucetType){
                        //这里需要判断是否计划是否已经被执行，预编译文件等待更新接口

                        staking.execute_candidate_bond_less(address(this));
                    }else {
                        //这里需要判断是否计划是否已经被执行
                        if(staking.delegation_request_is_pending(address(this), collatorAddr)){
                            staking.schedule_delegator_bond_less(collatorAddr, info.amount);
                        }                        
                    }
                    Address.sendValue(payable(Igovern.stkTokenAddr()), info.amount);
                    leaseTotal = leaseTotal.sub(info.amount);
                    Iairdrop.unlockLeaseMargin(info.reddeemAddr,leaseDate,info.marginAmount);
                    break;
                }
            }
        }
    }

    //添加NimbusId，用于绑定钱包奖励(收集人)
    function addAssociation(bytes32 newNimbusId) public isOwner(){
        require(faucetType && bstate,'not collator!');
        require(address(this).balance >= Igovern.authorAmount(),'balance not enough!');
        authorMapping.add_association(newNimbusId);
        nimbusId = newNimbusId;
        associationFlag = true;
    }

    //更新NimbusId(收集人)
    function updateAssociation(bytes32 oldNimbusId,bytes32 newNimbusId) public isOwner(){
        require(associationFlag,'Association not binded!');
        authorMapping.update_association(oldNimbusId,newNimbusId);
        nimbusId = newNimbusId;
    }

    // //注册key(收集人)
    // function registerKeys(bytes32 authorId,bytes32 keys) public isOwner(){
    //     require(associationFlag,'Association not binded!');
    //     authorMapping.register_keys(authorId,keys);
    // }

    // //更新key(收集人)
    // function setKeys(
    //     bytes32 oldAuthorId,
    //     bytes32 newAuthorId,
    //     bytes32 newKeys
    // ) public isOwner(){
    //     require(associationFlag,'Association not binded!');
    //     authorMapping.set_keys(oldAuthorId,newAuthorId,newKeys);
    // }

    //赎回authorid映射绑定(收集人)（定时器执行）
    function redemmAssociation() public{
        require(faucetType && !associationFlag,'Association binded!');
        require(address(this).balance >= Igovern.authorAmount(),'balance not enough!');
        //判断区块高度是否到达设定高度
        require(leaveNumber.add(Igovern.blockHeight()) <= block.number,'not yet reached!');
        leaveNumber = 0;
        Address.sendValue(payable(Igovern.stkTokenAddr()), Igovern.authorAmount());
    }

    //原生质押token余额
    function balance() public view returns(uint256){
        return address(this).balance;
    }
}