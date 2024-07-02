// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";

interface ITeleporterRegistry {
    function VALIDATORS_SOURCE_ADDRESS() external view returns (address);
    function WARP_MESSENGER() external view returns (address);
    function blockchainID() external view returns (bytes32);
    function MAX_VERSION_INCREMENT() external view returns (uint256);
    function latestVersion() external view returns (uint256);
    function addProtocolVersion(uint32 messageIndex) external;
    function getLatestTeleporter() external view returns (ITeleporterMessenger);
    function getTeleporterFromVersion(uint256 version) external view returns (ITeleporterMessenger);
    function getAddressFromVersion(uint256 version) external view returns (address);
    function getVersionFromAddress(address protocolAddress) external view returns (uint256);
}
