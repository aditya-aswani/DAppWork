// SPDX-License-Identifier: MIT
//This contract was made to primarily test the lockup period feature.

pragma solidity ^0.8.0;

contract BountyTest {
    address public owner_address;
    string public bounty_name;
    uint256 public bounty_amount;
    string public bounty_link;
    address public oracle;
    uint256 bounty_creation_time;
    int256 bounty_lockup_seconds;
    string public hunter_github_id;

    enum BOUNTY_STATE {
        OPEN,
        AWAITING_CLAIM,
        CLOSED,
        CANCELED
    }
    BOUNTY_STATE public bounty_state;

    constructor(
        string memory _bounty_name,
        string memory _bounty_link,
        int256 _bounty_lockup_seconds
    ) {
        owner_address = msg.sender;
        bounty_name = _bounty_name;
        bounty_link = _bounty_link;
        bounty_state = BOUNTY_STATE.OPEN;
        oracle = 0xFd1A5a86f7017E600b84087f4f0071565f42C1B7;
        bounty_creation_time = block.timestamp;
        bounty_lockup_seconds = _bounty_lockup_seconds;
    }

    function view_bounty()
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint256,
            BOUNTY_STATE,
            uint256,
            int256,
            string memory
        )
    {
        return (
            owner_address,
            bounty_name,
            bounty_link,
            bounty_amount,
            bounty_state,
            bounty_creation_time,
            bounty_lockup_seconds,
            hunter_github_id
        );
    }

    modifier onlyOwner() {
        require(msg.sender == owner_address);
        _;
    }

    function withdraw_bounty() public payable onlyOwner {
        require(
            bounty_state == BOUNTY_STATE.OPEN,
            "This bounty is already closed."
        );
        require(
            int256(block.timestamp) >
                int256(bounty_creation_time) + bounty_lockup_seconds,
            "Bounties must be open for at least the lockup duration before they can be closed and have their funds withdrawn by the owner."
        );
        payable(msg.sender).transfer(address(this).balance);
        bounty_amount = address(this).balance;
        bounty_state = BOUNTY_STATE.CANCELED;
    }

    function fund_bounty() public payable onlyOwner {
        require(
            bounty_state == BOUNTY_STATE.OPEN,
            "This bounty is already closed."
        );
        bounty_amount = address(this).balance;
    }

    modifier onlyOracle() {
        require(msg.sender == oracle);
        _;
    }

    function close_bounty(address _bounty_winner) public payable onlyOracle {
        require(
            bounty_state == BOUNTY_STATE.OPEN,
            "This bounty is already closed."
        );
        payable(_bounty_winner).transfer(address(this).balance);
        bounty_amount = address(this).balance;
        bounty_state = BOUNTY_STATE.CLOSED;
    }

    function change_hunter_github_id(string memory _hunter_github_id)
        public
        onlyOracle
    {
        require(
            bounty_state == BOUNTY_STATE.OPEN,
            "This bounty is already closed."
        );
        hunter_github_id = _hunter_github_id;
        bounty_state = BOUNTY_STATE.AWAITING_CLAIM;
    }
}
