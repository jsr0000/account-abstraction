// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../script/DeployMinimal.s.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {SendPackedUserOp, PackedUserOperation, IEntryPoint} from "../script/SendPackedUserOp.s.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;
    MinimalAccount minimalAccount;
    HelperConfig helperConfig;
    ERC20Mock usdc;
    SendPackedUserOp senderPackedUserOp;

    uint256 constant USDC_AMOUNT = 1e18;
    address randomUser = makeAddr("randomUser");
    function setUp() public {
        DeployMinimal deployer = new DeployMinimal();
        (helperConfig, minimalAccount) = deployer.deployMinimalAccount();
        usdc = new ERC20Mock();
        senderPackedUserOp = new SendPackedUserOp();
    }

    function testOwnerCanExecuteCommands() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );

        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, functionData);

        assertEq(usdc.balanceOf(address(minimalAccount)), USDC_AMOUNT);
    }

    function testNonOwnerCannotExecuteCommands() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );

        vm.prank(randomUser);
        vm.expectRevert(
            MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector
        );
        minimalAccount.execute(dest, value, functionData);
    }

    function testRecoverSignedOp() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );
        bytes memory executeCallData = abi.encodeWithSelector(
            MinimalAccount.execute.selector,
            dest,
            value,
            functionData
        );
        PackedUserOperation memory packedUserOp = senderPackedUserOp
            .generateSignedUserOperation(
                executeCallData,
                helperConfig.getConfig(),
                address(minimalAccount)
            );
        bytes32 userOperationHash = IEntryPoint(
            helperConfig.getConfig().entryPoint
        ).getUserOpHash(packedUserOp);

        // Act
        address actualSigner = ECDSA.recover(
            userOperationHash.toEthSignedMessageHash(),
            packedUserOp.signature
        );

        // Assert
        assertEq(actualSigner, minimalAccount.owner());
    }

    function testValidationOfUserOps() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );
        bytes memory executeCallData = abi.encodeWithSelector(
            MinimalAccount.execute.selector,
            dest,
            value,
            functionData
        );
        PackedUserOperation memory packedUserOp = senderPackedUserOp
            .generateSignedUserOperation(
                executeCallData,
                helperConfig.getConfig(),
                address(minimalAccount)
            );
        bytes32 userOperationHash = IEntryPoint(
            helperConfig.getConfig().entryPoint
        ).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 1e18;

        // Act
        vm.prank(helperConfig.getConfig().entryPoint);
        uint256 validationData = minimalAccount.validateUserOp(
            packedUserOp,
            userOperationHash,
            missingAccountFunds
        );
        assertEq(validationData, 0);
    }

    function testEntryPointCanExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            USDC_AMOUNT
        );
        bytes memory executeCallData = abi.encodeWithSelector(
            MinimalAccount.execute.selector,
            dest,
            value,
            functionData
        );
        PackedUserOperation memory packedUserOp = senderPackedUserOp
            .generateSignedUserOperation(
                executeCallData,
                helperConfig.getConfig(),
                address(minimalAccount)
            );
        // bytes32 userOperationHash = IEntryPoint(
        //     helperConfig.getConfig().entryPoint
        // ).getUserOpHash(packedUserOp);
        vm.deal(address(minimalAccount), 1e18);

        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = packedUserOp;

        // Act
        vm.prank(randomUser);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(
            ops,
            payable(randomUser)
        );

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), USDC_AMOUNT);
    }
}
