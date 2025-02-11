// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "./ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IFaucet{
    function initialize (
        address _governAddr,
        address _collatorAddr,
        address _techAddr,
        address _owner,
        bool _faucetType
    ) external;
    function setLeaseInfo(
        address _reddeemAddr,
        uint _leaseDate,
        uint _period,
        uint256 _amount,
        uint256 _marginAmount
    ) external;
}

interface IGovernance{
    function getPerInvestDownLimit() external view returns(uint);
    function getFundsUpLimit() external view returns(uint);  
    function getRedeemTimeLimit() external  view returns(uint);  
    function setStkTokenAddr(address _stkTokenAddr) external;
    function retTokenAddr() external view returns (address);
    function rewardAddr() external view returns (address);
    function getMarginProportion() external  view returns(uint);
    function getReserveProportion() external  view returns(uint);
    function authorAmount() external view returns(uint256);
}

interface IAirdrop{
    function burn(address _account, uint256 _amount) external returns (bool);
    function balanceOf(address _account) external view returns (uint256);
    function lockLeaseMargin(
        address _from,
        address _leaseAddr,
        uint _leaseDate,
        uint _period,
        uint256 _amount
    ) external returns (bool);
}

contract Pool is ERC20{
    using SafeMath for uint256;

    IGovernance public Igovern;
    IAirdrop public Iairdrop;

    //faucet模板地址
    address public faucetModelAddr;

    //质押成员地址
    mapping(uint => address) public memberAddrs;
    //质押开始时间
    mapping(address => uint256) public memberTimes;
    //质押成员总数
    uint public memberTotal = 0;
    //收集人地址集
    mapping(address => address[]) private collatorAddrs;
    //委托人地址集
    mapping(address => address[]) private delegatorAddrs;
    //lock锁
    bool private unlocked = true;
    
    constructor() ERC20('stkTokenName','stkTokenSymbol'){        
    }

    //克隆合约初始化调用
    function initialize (
        address _governAddr,
        string memory name_,
        string memory symbol_,
        address _faucetModelAddr
    ) external{
        require(address(Igovern) == address(0),'Igovern seted!');
        Igovern = IGovernance(_governAddr);
        _name = name_;
        _symbol = symbol_;
        faucetModelAddr = _faucetModelAddr;
        //设置Government的stkToken地址
        Igovern.setStkTokenAddr(address(this));
        //克隆合约需要初始化非默认值非constant的参数值
        unlocked = true;
    }

    modifier lock() {
        require(unlocked, 'Pool: LOCKED!');
        unlocked = false;
        _;
        unlocked = true;
    }

    //克隆合约
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    //重写_beforeTokenTransfer,用于控制memberAddrs、memberTimes、memberTotal
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if(to != address(0)){
            if(memberTimes[to] == 0){
                memberAddrs[memberTotal] = to;
                memberTotal = memberTotal.add(1);
            }
            memberTimes[to] = block.timestamp;
        }
    }
    
    //计算当前所需保证金,_stkAmount单位为Wei
    function getMarginCount(uint256 _stkAmount) private returns(uint256){
        require(Igovern.retTokenAddr()!=address(0),'retTokenAddr is not set!');
        require((address(this).balance).sub(_stkAmount) >= totalSupply().mul(Igovern.getReserveProportion()).div(100),'Balance is not enough!');        
        uint256 marginAmount = _stkAmount.mul(Igovern.getMarginProportion()).div(10);
        Iairdrop = IAirdrop(Igovern.retTokenAddr());
        require(Iairdrop.balanceOf(msg.sender) >= _stkAmount.add(marginAmount),'retToken is not enough!');
        return marginAmount;
    }

    //设置faucet基本信息,_stkAmount、_marginAmount、_authorAmount单位为Wei
    function setFaucetInfo(
        IFaucet _faucet,
        uint _period,
        uint256 _stkAmount,
        uint256 _marginAmount,
        uint256 _authorAmount
    ) private{
        //delegator设置按地址日期租赁时限记录的租赁信息   
        uint leaseDate = block.timestamp.div(24 * 60 * 60);
        _faucet.setLeaseInfo(msg.sender,leaseDate,_period,_stkAmount,_marginAmount);
        Address.sendValue(payable(address(_faucet)),_stkAmount.add(_authorAmount));
        Iairdrop.burn(msg.sender,_stkAmount.add(_authorAmount));
        //发送保证金marginAmount到airdrop合约锁定       
        Iairdrop.lockLeaseMargin(msg.sender,address(_faucet),leaseDate,_period,_marginAmount);
    }

    //DAO质押
    function addStake() public payable {
        require(msg.value >= Igovern.getPerInvestDownLimit(),'Less than perInvestDownLimit!');
        require(totalSupply() <= Igovern.getFundsUpLimit(),'More than getFundsUpLimit!');        
        _mint(msg.sender, msg.value);
    }

    //质押赎回,_amount单位为Wei
    function redeemStake(uint256 _amount) public{
        require(_amount > 0,'Amount is zero!');
        require(balanceOf(msg.sender) >= _amount && address(this).balance >= _amount,'Balance is not enough!');
        uint day = (block.timestamp).sub(memberTimes[msg.sender]).div(60 * 60 *24);
        require(day >= Igovern.getRedeemTimeLimit(),'RedeemTimeLimit is not yet');
        Address.sendValue(payable(msg.sender), _amount);
        _burn(msg.sender,_amount);
    }

    //创建合约收集人（水龙头）,_stkAmount单位为Wei
    function createCollator(
        address _techAddr,
        uint _period,
        uint256 _stkAmount
    ) public lock returns(address){
        require(faucetModelAddr != address(0),'faucetModelAddr is not set!');
        require(Igovern.rewardAddr() != address(0),'rewardAddr is not set!');        
        uint256 marginAmount = getMarginCount(_stkAmount.add(Igovern.authorAmount()));
        //创建收集人
        IFaucet collator = IFaucet(createClone(faucetModelAddr)); 
        collator.initialize(address(Igovern),address(0),_techAddr,msg.sender,true); 
        address[] storage addrs = collatorAddrs[msg.sender];
        addrs.push(address(collator));
        collatorAddrs[msg.sender] = addrs;
        setFaucetInfo(collator,_period,_stkAmount,marginAmount,Igovern.authorAmount());
        return address(collator);
    }

    //增加合约收集人选票,_stkAmount单位为Wei
    function addCollator(
        address payable _collatorAddr,
        uint _period,
        uint256 _stkAmount
    ) public lock{
        uint256 marginAmount = getMarginCount(_stkAmount);  
        IFaucet collator = IFaucet(_collatorAddr); 
        setFaucetInfo(collator,_period,_stkAmount,marginAmount,0);
    }

    //创建合约委托人（水龙头）,_stkAmount单位为Wei
    function createDelegator(
        address _collatorAddr,
        uint _period,
        uint256 _stkAmount
    ) public lock returns(address){
        require(faucetModelAddr != address(0),'faucetModelAddr is not set!');
        require(Igovern.rewardAddr() != address(0),'rewardAddr is not set!');
        //计算当前所需retToken,预留保证金
        uint256 marginAmount = getMarginCount(_stkAmount); 
        //创建委托人
        IFaucet delegator = IFaucet(createClone(faucetModelAddr));
        delegator.initialize(address(Igovern),_collatorAddr,address(0),address(0),false);
        address[] storage addrs = delegatorAddrs[msg.sender];
        addrs.push(address(delegator));
        delegatorAddrs[msg.sender] = addrs;

        setFaucetInfo(delegator,_period,_stkAmount,marginAmount,0);
        return address(delegator);
    }
    
    //增加合约委托人选票,_stkAmount单位为Wei
    function addDelegator(
        address payable _delegatorAddr,
        uint _period,
        uint256 _stkAmount
    ) public lock{
        uint256 marginAmount = getMarginCount(_stkAmount); 
        IFaucet delegator = IFaucet(_delegatorAddr);
        setFaucetInfo(delegator,_period,_stkAmount,marginAmount,0);
    }

    //获取委托人地址集
    function getDelegatorAddrs(address _account) public view returns(address[] memory){
        return delegatorAddrs[_account];
    }

    //获取收集人地址集
    function getCollatorAddrs(address _account) public view returns(address[] memory){
        return collatorAddrs[_account];
    }

    //原生质押token余额
    function balance() public view returns(uint256){
        return address(this).balance;
    }

    //从faucet获取token所需rettoken数量
    function getRetToken(uint256 amount) public view returns(uint256) {
        return amount.add(amount.mul(Igovern.getMarginProportion()).div(10));
    }
}