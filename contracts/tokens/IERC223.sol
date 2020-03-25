pragma solidity ^0.5.14;


contract IERC223 {
  /**
   * @dev Returns the total supply of the token.
   */
  uint public _totalSupply;

  /**
   * @dev Returns the balance of the `who` address.
   */
  function balanceOf(address who) public view returns (uint);

  /**
   * @dev Transfers `value` tokens from `msg.sender` to `to` address
   * and returns `true` on success.
   */
  function transfer(address to, uint value) public returns (bool success);

  /**
   * @dev Transfers `value` tokens from `msg.sender` to `to` address with `data` parameter
   * and returns `true` on success.
   */
  function transfer(address to, uint value, bytes memory data) public returns (bool success);

  /**
  * @dev Event that is fired on successful transfer.
  */
  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
