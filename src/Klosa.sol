// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable2Step} from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract Klosa is Ownable2Step, AccessControl {
    bytes32 public constant IS_PRODUCTADMIN = keccak256("IS_PRODUCTADMIN");

    mapping(address => string[]) private purchasedProducts;
    mapping(uint256 => Product[]) private productId;
    mapping(string => bool) private productExists; // Track existing products names

    // Keep track of the known adminProducts and addedProducts
    mapping(address => Product[]) private adminProducts;

    mapping(uint256 => Product) private products;

    mapping(uint256 => Category) private categories;

    uint256 private productIDMappingLength;

    struct Product {
        string productName;
        string description;
        string image;
        uint256 productId;
        string categoryName;
        string subCategory;
        uint256 price;
    }

    struct Category {
        string categoryName;
        string categoryDescription;
    }

    event ProductCreated(uint256 productId, string name, uint256 price);
    event ProductUpdated(uint256 productId, string name, uint256 price);
    event ProductDeleted(uint256 productId);
    event ProductCreatorAdded(address creator);
    event ProductCreatorRemoved(address creator);
    event FundsWithdrawn(uint256 amount);
    event CategoryAdded(uint256 categoryId, string name, string description);
    event ReceivedEther(address sender, uint256 value);
    event ProductBought(
        uint256 _productId,
        string productName,
        uint256 price,
        address
    );

    constructor() payable {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // gives admin role to the deployer address
        _grantRole(IS_PRODUCTADMIN, msg.sender); // gives admin role to the deployer address
    }

    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }

    /**
     * @notice Function that creates a new product by any address with IS_PRODUCTADMIN access
     * @param _productName Name of product
     * @param _description product description
     * @param _image url pointing to the image
     * @param _productId Id of product
     * @param _categoryName product category
     * @param _subCategory Product subcategory
     * @param _price product price
     */
    function createProduct(
        string memory _productName,
        string memory _description,
        string memory _image,
        uint256 _productId,
        string memory _categoryName,
        string memory _subCategory,
        uint256 _price
    ) external onlyRole(IS_PRODUCTADMIN) {
        require(
            bytes(_productName).length > 0,
            "Product name cannot be empty."
        );
        require(
            bytes(_description).length > 0,
            "Product description cannot be empty."
        );
        require(bytes(_image).length > 0, "Product image cannot be empty.");
        require(_productId > 0, "Product productId cannot be empty.");
        require(
            bytes(_categoryName).length > 0,
            "Product _categoryName cannot be empty."
        );
        require(
            bytes(_subCategory).length > 0,
            "Product _subCategory cannot be empty."
        );
        require(_price > 0, "Product price cannot be less than zero.");
        require(
            !productExists[_productName],
            "Product with this name already exists."
        );

        // Create a new product
        Product memory newProduct = Product({
            productName: _productName,
            description: _description,
            image: _image,
            productId: _productId,
            categoryName: _categoryName,
            subCategory: _subCategory,
            price: _price
        });

        // Add the new product to the products mapping
        products[_productId] = newProduct;

        // Add the new product to the productId mapping
        productId[_productId].push(newProduct);

        // Add the new product to the IS_PRODUCTADMIN's product
        adminProducts[msg.sender].push(newProduct);

        // Mark the product name as existing
        productExists[_productName] = true;

        productIDMappingLength++;

        emit ProductCreated(_productId, _productName, _price);
    }

    /**
     * @notice This function create new category
     * @param categoryId Id to be associated with the product category
     * @param _categoryName category name
     * @param _categoryDescription category description
     */
    function createCategory(
        uint256 categoryId,
        string memory _categoryName,
        string memory _categoryDescription
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            bytes(_categoryName).length > 0,
            "Product _categoryName cannot be empty."
        );
        require(
            bytes(_categoryDescription).length > 0,
            "Product _categoryDescription cannot be empty."
        );
        // require(
        //     categories[categoryId].categoryName == "",
        //     "Category with this ID already exists"
        // );

        Category memory newCategory = Category({
            categoryName: _categoryName,
            categoryDescription: _categoryDescription
        });

        categories[categoryId] = newCategory;
        emit CategoryAdded(categoryId, _categoryName, _categoryDescription);
    }

    /**
     * @notice this function is called by a buyer to get a specific product using the assigned id
     * @param _productId assigned id of the product to be bought
     */
    function buyProduct(uint256 _productId) public payable {
        // Check if the product with the given ID exists
        Product storage product = products[_productId];
        require(
            bytes(product.productName).length > 0,
            "Product with this ID does not exist."
        );

        // Check if the sent ether matches the product price
        require(msg.value >= product.price, "Incorrect payment amount.");

        // Transfer the product to the buyer (msg.sender)
        purchasedProducts[msg.sender].push(product.productName);

        // Transfer the payment to the contract
        payable(address(this)).transfer(msg.value);
        emit ProductBought(
            _productId,
            product.productName,
            product.price,
            msg.sender
        );
    }

    function getProductByBuyer(
        address buyer
    ) public view returns (string[] memory) {
        return purchasedProducts[buyer];
    }

    function getProductById(
        uint256 _productId
    )
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            uint256,
            string memory,
            string memory,
            uint256
        )
    {
        require(
            bytes(products[_productId].productName).length > 0,
            "Product with this ID does not exist."
        );

        Product memory product = products[_productId];
        return (
            product.productName,
            product.description,
            product.image,
            product.productId,
            product.categoryName,
            product.subCategory,
            product.price
        );
    }

    function supermarketDetail(
        string memory _name,
        string memory _location,
        uint256 rating
    ) public {}

    function withdrawFunds() public onlyOwner {
        // Withdraw the contract balance to the owner
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds available for withdrawal.");
        payable(owner()).transfer(contractBalance);

        emit FundsWithdrawn(contractBalance);
    }

    function getAllProducts() public view returns (Product[] memory) {
        uint256 productCount = 0;

        // Count the number of products
        for (uint256 i = 1; i <= productIDMappingLength; i++) {
            productCount += productId[i].length;
        }

        // Initialize an array to store all products
        Product[] memory allProducts = new Product[](productIDMappingLength);

        // Populate the array with product details
        uint256 currentIndex = 0;
        for (uint256 i = 1; i <= productIDMappingLength; i++) {
            Product[] storage productArray = productId[i];
            for (uint256 j = 0; j < productArray.length; j++) {
                allProducts[currentIndex] = productArray[j];
                currentIndex++;
            }
        }

        return allProducts;
    }
}
