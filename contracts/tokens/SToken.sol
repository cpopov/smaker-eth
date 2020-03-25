pragma solidity 0.5.14;

import "./MintableToken.sol";
import "./BurnableToken.sol";

contract SToken is MintableToken {

  // meta data
  string public constant version = '0.1';
  uint public constant decimals = 18;
  string public symbol;
  string public name;
  bool public short;

  // data
  uint public price;


  /**
  *
  * @param initialBalance balance (18 decimals)
  * @param _name name
  * @param _symbol unique token symbol
  * @param _short is it a short?
  */
  constructor(uint initialBalance, string memory _symbol, string memory _name, bool _short) public {
    symbol = _symbol;
    name = _name;
    short = _short;
    _mint(msg.sender, initialBalance);
  }

  /**
   * @dev Burns a specific amount of tokens.
   * @param _account The address of the token holder
   * @param _value The amount of token to be burned.
   */
  function burn(address _account, uint _value) public onlyOwner returns (bool success) {
    _burn(_account, _value);
    return true;
  }

}
