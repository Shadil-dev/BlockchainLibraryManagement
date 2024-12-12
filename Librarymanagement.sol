// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Library {
    struct Book {
        string bookname;
        uint256 bookid;
        bool isAvailable;
        address borrower;
    }

    mapping(uint256 => Book) public books;
    mapping(address => uint256[]) public bookusers;
    uint256[] public Book_booksid;

    event BookBorrowed(uint256 indexed _bookId, address indexed _borrower);
    event BookReturned(uint256 indexed _bookId, address indexed _borrower);
    event BookAdded(uint256 indexed _bId, string title);

    constructor() {
        AddBook(1, "DLT");
        AddBook(2, "Hyperledger Fabric");
        AddBook(3, "Docker for Distributed Ledger Technology");
    }

    function AddBook(uint256 _bId, string memory _bookname) public {
        require(!books[_bId].isAvailable, "Book is already present");
        books[_bId] = Book(_bookname, _bId, true, address(0));
        Book_booksid.push(_bId); 
        emit BookAdded(_bId, _bookname);
    }

    function BorrowBook(uint256 _bookId) external {
        require(books[_bookId].isAvailable, "Book is not available");

        books[_bookId].borrower = msg.sender;
        books[_bookId].isAvailable = false;

        bookusers[msg.sender].push(_bookId);
        emit BookBorrowed(_bookId, msg.sender);
    }

    function ReturnBook(uint256 _bookId) external {
        require(!books[_bookId].isAvailable, "Book is not borrowed");
        require(books[_bookId].borrower == msg.sender, "You are not the borrower");

        books[_bookId].isAvailable = true;
        books[_bookId].borrower = address(0);

        emit BookReturned(_bookId, msg.sender);
        releaseuser(_bookId, msg.sender);
    }

    function releaseuser(uint256 _bookId, address user) private {
        uint256[] storage borrowedBooks = bookusers[user];
        for (uint256 i = 0; i < borrowedBooks.length; i++) {
            if (borrowedBooks[i] == _bookId) {
                borrowedBooks[i] = borrowedBooks[borrowedBooks.length - 1];
                borrowedBooks.pop();
                break;
            }
        }
    }

    function userbookdetails(address user) external view returns (uint256[] memory) {
        return bookusers[user];
    }

    function booksavailable() external view returns (string[] memory) {
        string[] memory availableBooks = new string[](Book_booksid.length);
        for (uint256 i = 0; i < Book_booksid.length; i++) {
            uint256 bookId = Book_booksid[i];
            availableBooks[i] = books[bookId].bookname;
        }
        return availableBooks;
    }
}