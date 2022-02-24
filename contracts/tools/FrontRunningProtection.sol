// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *@dev FrontRunningProtection class usef for commit-reveal schemes with deadline.
 * We don't emit events to not broadcast the commits, devs will have to use the getter.
 */
contract FrontRunningProtection {

    mapping(bytes32 => uint256) private _commits;

    /**
     * Use it to enforce the need of a previous commit within duration
     * Will consume the commit if we are within deadline
     * @param commit the commit ID
     * @param duration duration in miliseconds
     */
    modifier frontrunProtected(bytes32 commit, uint256 duration) {
        uint256 timestamp = _commits[commit];
        require(duration == 0 || (timestamp != 0 && timestamp + duration <= block.timestamp), "Commit not ready");
        delete _commits[commit];
        _;
    }

    /**
     * Gets duration for a commit
     * @param commit ID
     * @return commit duration or zero if not found
     */
    function getCommitTimestamp(bytes32 commit) external view returns(uint256) {
        return _commits[commit];
    }

    /**
     * Saves commits deadline if commit does not exist
     * @param commit id
     */
    function _frontrunCommit(bytes32 commit) internal {
        require(_commits[commit] == 0, "Commit already exists");
        _commits[commit] = block.timestamp;
    }

}