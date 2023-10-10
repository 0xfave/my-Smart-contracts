// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {OwnableRoles} from "lib/solady/src/auth/OwnableRoles.sol";

/**
 * @title MedicalLabs
 * @dev Favour (@0xFave)
 * @notice Manages product creation, removal and funds management
 */

contract MedicalLab is OwnableRoles {
    // Internal
    // Private
    // External
    // Public

    // ======================= Roles ======================= //
    uint256 internal constant DEFAULT_ADMIN_ROLE = 1 << 0;
    uint256 internal constant IS_PRODUCT_CREATOR = 1 << 1;

    // @dev this stores the total funds in the smart contract
    uint256 public totalFunds;

    struct Product {
        string name;
        uint256 price;
    }

    mapping(uint256 => Product) public products;
    mapping(address => bool) public productCreators;

    // ======================= Event ======================= //
    event ProductCreated(uint256 productId, string name, uint256 price);
    event ProductUpdated(uint256 productId, string name, uint256 price);
    event ProductDeleted(uint256 productId);
    event ProductCreatorAdded(address creator);
    event ProductCreatorRemoved(address creator);
    event FundsWithdrawn(uint256 amount);

    // ===================== Constructor ===================== //
    constructor() {
        _grantRoles(msg.sender, DEFAULT_ADMIN_ROLE);
        _grantRoles(msg.sender, IS_PRODUCT_CREATOR);
    }

    // ================== Public Functions ================== //
    function createProduct(
        uint256 productId,
        string memory name,
        uint256 price
    ) public onlyRoles(IS_PRODUCT_CREATOR) {
        require(bytes(name).length > 0, "Product name cannot be empty");
        require(price > 0, "Product price must be greater than zero");

        products[productId] = Product(name, price);
        emit ProductCreated(productId, name, price);
    }

    function readProduct(
        uint256 productId
    ) public view returns (string memory name, uint256 price) {
        Product memory product = products[productId];
        return (product.name, product.price);
    }

    function updateProduct(
        uint256 productId,
        string memory newName,
        uint256 newPrice
    ) public onlyRoles(IS_PRODUCT_CREATOR) {
        require(bytes(newName).length > 0, "Product name cannot be empty");
        require(newPrice > 0, "Product price must be greater than zero");

        Product storage product = products[productId];
        product.name = newName;
        product.price = newPrice;
        emit ProductUpdated(productId, newName, newPrice);
    }

    function deleteProduct(
        uint256 productId
    ) public onlyRoles(IS_PRODUCT_CREATOR) {
        delete products[productId];
        emit ProductDeleted(productId);
    }

    // ====================== OnlyOwner ====================== //
    function withdrawFunds() public onlyOwner {
        require(totalFunds > 0, "No funds available for withdrawal");
        uint256 amountToWithdraw = totalFunds;
        totalFunds = 0;
        payable(msg.sender).transfer(amountToWithdraw);
        emit FundsWithdrawn(amountToWithdraw);
    }
}
