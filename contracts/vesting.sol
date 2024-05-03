// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./TransferHelper.sol";


contract vesting is Ownable, ReentrancyGuard{
    IERC20 public token;
    address public Owner;
    address public teamAddress;
    address public advisorAddress; 
    address public privateInvestorAddress; 
    address public seedInvestorAddress;
    address public preSeedInvestorAddress;
    uint256 public strartTime;

    // Struct to hold vesting details for each allocation
    struct VestingSchedule {
        uint256 claimCount;
        uint256 totalAmount;
        uint256 cliff;
        uint256 duration;
        uint256 interval;
    }

    // Vesting schedules for different allocations
    VestingSchedule public teamVesting = VestingSchedule({
        claimCount : 0,
        totalAmount: 15_000_000 * 10**18,
        cliff: 1 seconds,
        duration: 195 seconds,
        interval: 90 seconds // Quarterly
    });

    VestingSchedule public advisorsVesting = VestingSchedule({
        claimCount : 0,
        totalAmount: 5_000_000 * 10**18,
        cliff: 730 seconds,
        duration: 1095 seconds,
        interval: 90 seconds // Quarterly
    });

    VestingSchedule public privateInvestorsVesting = VestingSchedule({
        claimCount : 0,
        totalAmount: 10_000_000 * 10**18,
        cliff: 30 days, // 1 month
        duration: 365 days,
        interval: 7 days // Weekly
    });

    VestingSchedule public seedInvestorsVesting = VestingSchedule({
        claimCount : 0,
        totalAmount: 5_000_000 * 10**18,
        cliff: 30 days, // 1 month
        duration: 365 days,
        interval: 7 days // Weekly
    });

    VestingSchedule public preSeedInvestorsVesting = VestingSchedule({
        claimCount : 0,
        totalAmount: 6_250_000 * 10**18,
        cliff: 30 days, // 1 month
        duration: 365 days,
        interval: 7 days // Weekly
    });

    constructor(address _token, address _teamAddress, address _advisorAddress, address _privateInvestorAddress, address _seedInvestorAddress, address _preSeedInvestorAddress) Ownable(msg.sender) {
        token = IERC20(_token);
        teamAddress = _teamAddress;
        advisorAddress = _advisorAddress;
        privateInvestorAddress = _privateInvestorAddress;
        seedInvestorAddress = _seedInvestorAddress;
        preSeedInvestorAddress = _preSeedInvestorAddress;
        Owner = msg.sender;
        strartTime = block.timestamp;
    }

    function releaseTeamTokens() external  nonReentrant{
        require((msg.sender == Owner) || (msg.sender == teamAddress), "only Owner or Team wallet can send this call");
        VestingSchedule storage schedule = teamVesting;
        require(block.timestamp >= schedule.cliff + strartTime, "Cliff period has not passed yet");

        require(schedule.claimCount < 12, "you have claimed the full amount"); //duration (3years)/ interval (3months) = 12
        uint256 vestingStartTime = strartTime + schedule.cliff;
        uint256 legitmateClaimNumber = uint256(((block.timestamp - vestingStartTime)/schedule.interval)+1);
        require(legitmateClaimNumber > schedule.claimCount, "maximum legitimate amount claimed for this epoch");
        schedule.claimCount ++;
        uint256 claimAmount = schedule.totalAmount/12; //duration (3years)/ interval (3months) = 12
        _release(claimAmount); //duration (3years)/ interval (3months) = 12
    } 

    function releaseAdvisorsTokens() external  nonReentrant{
        require((msg.sender == Owner) || (msg.sender == advisorAddress), "only Owner or Advisor wallet can send this call");
        VestingSchedule storage schedule = advisorsVesting;
        require(block.timestamp >= schedule.cliff + strartTime, "Cliff period has not passed yet");

        require(schedule.claimCount < 12, "you have claimed the full amount");//duration (3years)/ interval (3months) = 12
        uint256 vestingStartTime = strartTime + schedule.cliff;
        uint256 legitmateClaimNumber = uint256(((block.timestamp - vestingStartTime)/schedule.interval)+1);
        require(legitmateClaimNumber > schedule.claimCount, "maximum legitimate amount claimed for this epoch");
        schedule.claimCount ++;
        uint256 claimAmount = schedule.totalAmount/12; //duration (3years)/ interval (3months) = 12
        _release(claimAmount);
    }

    function releasePrivateInvestorsTokens() external  nonReentrant{
        require((msg.sender == Owner) || (msg.sender == privateInvestorAddress), "only Owner or Private Investor Wallet can send this call");
        VestingSchedule storage schedule = privateInvestorsVesting;
        require(block.timestamp >= schedule.cliff + strartTime, "Cliff period has not passed yet");
        require(schedule.claimCount < 49, "you have claimed the full amount");//interval 52 (number of weeks) - 4 (cliff weeks) + 1 (for claim payment of cliffed weeks) = 49
        if (schedule.claimCount == 0){
            schedule.claimCount ++;
            uint256 claimAmount = uint256(schedule.totalAmount*4/52); // total amount/52 = total ampunt per week, *4 for 4 weeks
            _release(claimAmount);
        }else{
                uint256 vestingStartTime = strartTime + schedule.cliff;
                uint256 legitmateClaimNumber = uint256((block.timestamp - vestingStartTime)/schedule.interval);
                require(legitmateClaimNumber +1 > schedule.claimCount, "maximum legitimate amount claimed for this epoch");
                uint256 claimAmount = uint256(schedule.totalAmount/52); // weekly amount = total amount / spread in 52 weeks
                schedule.claimCount ++;
                _release(claimAmount);
        }
    }

    function releaseSeedInvestorsTokens() external  nonReentrant{
        require((msg.sender == Owner) || (msg.sender == seedInvestorAddress), "only Owner or seed Investor Wallet can send this call");
        VestingSchedule storage schedule = seedInvestorsVesting;
        require(block.timestamp >= schedule.cliff + strartTime, "Cliff period has not passed yet");
        require(schedule.claimCount < 49, "you have claimed the full amount");//interval 52 (number of weeks) - 4 (cliff weeks) + 1 (for claim payment of cliffed weeks) = 49
        if (schedule.claimCount == 0){
            schedule.claimCount ++;
            uint256 claimAmount = uint256(schedule.totalAmount*4/52); // total amount/52 = total ampunt per week, *4 for 4 weeks
            _release(claimAmount);
        }else{
                uint256 vestingStartTime = strartTime + schedule.cliff;
                uint256 legitmateClaimNumber = uint256((block.timestamp - vestingStartTime)/schedule.interval);
                require(legitmateClaimNumber +1 > schedule.claimCount, "maximum legitimate amount claimed for this epoch");
                uint256 claimAmount = uint256(schedule.totalAmount/52); // weekly amount = total amount / spread in 52 weeks
                schedule.claimCount ++;
                _release(claimAmount);
        }
    }

    function releasePreSeedInvestorsTokens() external  nonReentrant{
        require((msg.sender == Owner) || (msg.sender == preSeedInvestorAddress), "only Owner or pre-seed Investor Wallet can send this call");
        VestingSchedule storage schedule = preSeedInvestorsVesting;
         require(block.timestamp >= schedule.cliff + strartTime, "Cliff period has not passed yet");
        require(schedule.claimCount < 49, "you have claimed the full amount");//interval 52 (number of weeks) - 4 (cliff weeks) + 1 (for claim payment of cliffed weeks) = 49
        if (schedule.claimCount == 0){
            schedule.claimCount ++;
            uint256 claimAmount = uint256(schedule.totalAmount*4/52); // total amount/52 = total ampunt per week, *4 for 4 weeks
            _release(claimAmount);
        }else{
                uint256 vestingStartTime = strartTime + schedule.cliff;
                uint256 legitmateClaimNumber = uint256((block.timestamp - vestingStartTime)/schedule.interval);
                require(legitmateClaimNumber +1 > schedule.claimCount, "maximum legitimate amount claimed for this epoch");
                uint256 claimAmount = uint256(schedule.totalAmount/52); // weekly amount = total amount / spread in 52 weeks
                schedule.claimCount ++;
                _release(claimAmount);
        }
    }

    function _release(uint256 amount) internal {
        require(amount > 0, "No tokens to release");
        TransferHelper.safeTransfer(address(token), msg.sender, amount);        
    }

    // In case the owner wants to withdraw any remaining tokens after the vesting
    function withdrawRemainingTokens() external {
    require( msg.sender == Owner, "only Owner or Team wallet can send this call");
        uint256 remainingTokens = token.balanceOf(address(this));
        require(remainingTokens > 0, "No remaining tokens");
        TransferHelper.safeTransfer(address(token), msg.sender, remainingTokens);
    }

}