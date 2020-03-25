
// File: contracts/tokens/ERC20.sol

pragma solidity 0.5.14;

/**
* Abstract contract(interface) for the full ERC 20 Token standard
* see https://github.com/ethereum/EIPs/issues/20
* This is a simple fixed supply token contract.
*/
contract ERC20 {

    /**
    * Get the total token supply
    */
    function totalSupply() public view returns (uint256 supply);

    /**
    * Get the account balance of an account with address _owner
    */
    function balanceOf(address _owner) public view returns (uint256 balance);

    /**
    * Send _value amount of tokens to address _to
    * Only the owner can call this function
    */
    function transfer(address _to, uint256 _value) public returns (bool success);

    /**
    * Send _value amount of tokens from address _from to address _to
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /** Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    * If this function is called again it overwrites the current allowance with _value.
    * this function is required for some DEX functionality
    */
    function approve(address _spender, uint256 _value) public returns (bool success);

    /**
    * Returns the amount which _spender is still allowed to withdraw from _owner
    */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    /**
    * Triggered when tokens are transferred from one address to another
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
    * Triggered whenever approve(address spender, uint256 value) is called.
    */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/library/SafeERC20.sol

pragma solidity 0.5.14;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20 _token,
    address _to,
    uint256 _value
  )
  internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
  internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
  internal
  {
    require(_token.approve(_spender, _value));
  }
}

// File: contracts/library/SafeMath.sol

pragma solidity 0.5.14;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0);
    // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/library/SignedSafeMath.sol

pragma solidity 0.5.14;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */
library SignedSafeMath {
  int256 constant private INT256_MIN = -2**255;

  /**
   * @dev Multiplies two signed integers, reverts on overflow.
   */
  function mul(int256 a, int256 b) internal pure returns (int256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    require(!(a == -1 && b == INT256_MIN), "SignedSafeMath: multiplication overflow");

    int256 c = a * b;
    require(c / a == b, "SignedSafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
   */
  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != 0, "SignedSafeMath: division by zero");
    require(!(b == -1 && a == INT256_MIN), "SignedSafeMath: division overflow");

    int256 c = a / b;

    return c;
  }

  /**
   * @dev Subtracts two signed integers, reverts on overflow.
   */
  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

    return c;
  }

  /**
   * @dev Adds two signed integers, reverts on overflow.
   */
  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

    return c;
  }
}

// File: contracts/tokens/StandardToken.sol

pragma solidity 0.5.14;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  mapping(address => mapping(address => uint256)) private allowed;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = (
    allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _account The account that will receive the created tokens.
   * @param _amount The amount that will be created.
   */
  function _mint(address _account, uint256 _amount) internal {
    require(_account != address(0));
    totalSupply_ = totalSupply_.add(_amount);
    balances[_account] = balances[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
  function _burn(address _account, uint256 _amount) internal {
    require(_account != address(0));
    require(_amount <= balances[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances[_account] = balances[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal _burn function.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
  function _burnFrom(address _account, uint256 _amount) internal {
    require(_amount <= allowed[_account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
    _burn(_account, _amount);
  }
}

// File: contracts/tokens/Ownable.sol

pragma solidity 0.5.14;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/tokens/MintableToken.sol

pragma solidity 0.5.14;




/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public hasMintPermission canMint returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

  // TODO add function to enable/disable minting
}

// File: contracts/tokens/BurnableToken.sol

pragma solidity 0.5.14;



/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public returns (bool success) {
    _burn(msg.sender, _value);
    return true;
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param _from address The address which you want to send tokens from
   * @param _value uint256 The amount of token to be burned
   */
  function burnFrom(address _from, uint256 _value) public returns (bool success) {
    _burnFrom(_from, _value);
    return true;
  }

  /**
   * @dev Overrides StandardToken._burn in order for burn and burnFrom to emit
   * an additional Burn event.
   */
  function _burn(address _who, uint256 _value) internal {
    _burn(_who, _value);
    emit Burn(_who, _value);
  }
}

// File: contracts/tokens/SToken.sol

pragma solidity 0.5.14;



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

// File: contracts/maker/SMaker.sol

pragma solidity 0.5.14;






contract SMaker is Ownable {
  using SafeMath for uint;
  using SafeMath for uint32;
  using SignedSafeMath for int;

  string public version = "0.1";
  string public symbol;
  string public name;
  uint32 public price;
  uint32 public priceTimestamp;
  uint32 public constant DECIMALS = 4;
  uint32 public constant PRICE_DENOMINATOR = 10 ** 4;
  uint32 public constant COLLATERAL_MARGIN = 20; // %
  uint32 public constant LIQUIDATION_LEVEL = 10; // %


  // collateral held by each token holder
  mapping(address => uint) internal collateral;

  struct Position {
    // SUM (entry_price * position_size)
    int netPosition;
    uint nbLongTokens;
    uint nbShortTokens;
  }

  mapping(address => Position) internal positions;

  address public oracle;
  ERC20 public collateralToken;
  SToken public longToken;
  SToken public shortToken;
  int public totalNetExposure;

  modifier onlyOracle() {
    require(msg.sender == oracle);
    _;
  }

  event TokenMinted (
    address indexed user,
    address indexed tokenAddr,
    string symbol,
    uint amount
  );

  event TokenBurned (
    address indexed user,
    address indexed tokenAddr,
    string symbol,
    uint amount
  );

  event TokensLiquidated (
    address indexed owner,
    address indexed tokenAddr,
    uint amount
  );

  /**
  *
  */
  constructor(string memory _symbol, address _collateralToken, address _shortToken, address _longToken, address _oracle) public {
    collateralToken = ERC20(_collateralToken);
    shortToken = SToken(_shortToken);
    longToken = SToken(_longToken);
    oracle = _oracle;
    symbol = _symbol;
  }

  function setPrice(uint32 _price) external onlyOracle {
    price = _price;
  }

  function setOracle(address _oracle) external onlyOwner {
    oracle = _oracle;
  }

  function getPosition() external view returns (int netPosition, uint nbLongTokens, uint nbShortTokens) {
    return (positions[msg.sender].netPosition, positions[msg.sender].nbLongTokens, positions[msg.sender].nbShortTokens);
  }

  /**
  * Get current Profit and Loss of an account
  */
  function getPnlOf(address accountOwner) internal view returns (int amount) {
    Position memory pos = positions[accountOwner];
    int pnl = int(price).mul(int(pos.nbLongTokens).sub(int(pos.nbShortTokens)).div(PRICE_DENOMINATOR)).sub(pos.netPosition);
    return pnl;
  }

  function getPnl() public view returns (int amount) {
    return getPnlOf(msg.sender);
  }

  function getCollateral() public view returns (uint amount) {
    return collateral[msg.sender];
  }

  function getRequiredCollateral() public view returns (uint amount) {
    return getRequiredCollateralOf(msg.sender, 0, true, COLLATERAL_MARGIN);
  }

  function getRequiredCollateralOf(address caller, uint amountToMint, bool long, uint32 margin) internal view returns (uint amount) {
    // min required collateral
    int netPosition = positions[caller].netPosition >= 0 ? positions[caller].netPosition : - positions[caller].netPosition;

    int netExposure;
    // considering new tokens
    if (long) {
      netExposure = netPosition.add(int(price.mul(amountToMint).div(PRICE_DENOMINATOR)));
    } else {
      netExposure = netPosition.sub(int(price.mul(amountToMint).div(PRICE_DENOMINATOR)));
    }

    // we need abs(netExposure)
    if (netExposure < 0) {
      netExposure = - netExposure;
    }

    int collateralMargin = netExposure.mul(int(margin)).div(100);

    // current profit and loss
    int requiredCollateral = collateralMargin.sub(getPnlOf(caller));

    if (requiredCollateral < 0) {
      return 0;
    } else {
      return uint(requiredCollateral);
    }
  }

  function transferCollateral(uint amount) public {
    transferCollateralFrom(msg.sender, amount);
  }

  function transferCollateralFrom(address sender, uint amount) internal {
    require(collateralToken.transferFrom(sender, address(this), amount), "Failed to transfer collateral");
    collateral[sender] = collateral[sender].add(amount);
  }

  function redeemCollateral(uint amount) external {
    address redeemer = msg.sender;
    uint requiredCollateral = getRequiredCollateralOf(redeemer, 0, true, COLLATERAL_MARGIN);
    require(collateral[redeemer] >= requiredCollateral.add(amount), "Minimal collateral is required");
    require(collateralToken.transfer(redeemer, amount), "Failed to transfer collateral back");
    collateral[redeemer] = collateral[redeemer].sub(amount);
  }

  /**
  * A user can mint a synthetic token provided he has deposited collateral
  */
  function mintLongTokens(uint amount) external {
    address caller = msg.sender;
    // Transfer collateral into the contract. Assumes caller has approved the transfer of the ERC20 token
    uint requiredCollateral = getRequiredCollateralOf(caller, amount, true, COLLATERAL_MARGIN);
    uint availableCollateral = collateral[caller];
    if (requiredCollateral > availableCollateral) {
      uint collateralToTransfer = requiredCollateral.sub(availableCollateral);
      transferCollateralFrom(caller, collateralToTransfer);
    }
    require(longToken.mint(caller, amount), "Failed to mint STokens");
    emit TokenMinted(caller, address(longToken), longToken.symbol(), amount);
    positions[caller].nbLongTokens = positions[caller].nbLongTokens.add(amount);
    positions[caller].netPosition = positions[caller].netPosition.add(int(amount.mul(price).div(PRICE_DENOMINATOR)));
  }

  /**
  * A user can mint a synthetic token provided he has deposited collateral
  */
  function mintShortTokens(uint amount) external {
    address caller = msg.sender;
    // Transfer collateral into the contract. Assumes caller has approved the transfer of the ERC20 token
    uint requiredCollateral = getRequiredCollateralOf(caller, amount, false, COLLATERAL_MARGIN);
    uint availableCollateral = collateral[caller];
    if (requiredCollateral > availableCollateral) {
      uint collateralToTransfer = requiredCollateral.sub(availableCollateral);
      transferCollateralFrom(caller, collateralToTransfer);
    }
    require(shortToken.mint(caller, amount), "Failed to mint STokens");
    emit TokenMinted(caller, address(shortToken), shortToken.symbol(), amount);
    positions[caller].nbShortTokens = positions[caller].nbShortTokens.add(amount);
    positions[caller].netPosition = positions[caller].netPosition.sub(int(amount.mul(price).div(PRICE_DENOMINATOR)));
  }

  function burnLongTokens(uint amount) external {
    address caller = msg.sender;
    require(longToken.burn(caller, amount), "Failed to burn STokens");
    emit TokenBurned(caller, address(longToken), longToken.symbol(), amount);
    positions[caller].nbLongTokens = positions[caller].nbLongTokens.sub(amount);
    positions[caller].netPosition = positions[caller].netPosition.sub(int(amount.mul(price).div(PRICE_DENOMINATOR)));
  }

  function burnShortTokens(uint amount) external {
    address caller = msg.sender;
    require(shortToken.burn(caller, amount), "Failed to burn STokens");
    emit TokenBurned(caller, address(shortToken), shortToken.symbol(), amount);
    positions[caller].nbShortTokens = positions[caller].nbShortTokens.sub(amount);
    positions[caller].netPosition = positions[caller].netPosition.add(int(amount.mul(price).div(PRICE_DENOMINATOR)));
  }

  function checkCollateral(address tokenHolder) public {
    uint liquidationCollateral = getRequiredCollateralOf(tokenHolder, 0, true, LIQUIDATION_LEVEL);
    uint col = collateral[tokenHolder];
    if (liquidationCollateral < collateral[tokenHolder]) {
      collateral[tokenHolder] = 0;
      // bye bye money
      emit TokensLiquidated(tokenHolder, address(collateralToken), col);
    }
  }
}

// File: contracts/tokens/IERC223.sol

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

// File: contracts/tokens/IERC223Recipient.sol

pragma solidity ^0.5.1;

/**
* @title Contract that will work with ERC223 tokens.
*/
contract IERC223Recipient {
  /**
   * @dev Standard ERC223 function that will handle incoming token transfers.
   *
   * @param _from  Token sender address.
   * @param _value Amount of tokens.
   * @param _data  Transaction metadata.
   */
  function tokenFallback(address _from, uint _value, bytes memory _data) public;
}

// File: contracts/library/Address.sol

pragma solidity ^0.5.14;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * This test is non-exhaustive, and there may be false-negatives: during the
   * execution of a contract's constructor, its address will be reported as
   * not containing a contract.
   *
   * > It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   */
  function isContract(address account) internal view returns (bool) {
    // This method relies in extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }

  /**
   * @dev Converts an `address` into `address payable`. Note that this is
   * simply a type cast: the actual underlying value is not changed.
   */
  function toPayable(address account) internal pure returns (address payable) {
    return address(uint160(account));
  }
}

// File: contracts/tokens/ERC223.sol

pragma solidity ^0.5.14;





/**
 * @title Reference implementation of the ERC223 standard token.
 */
contract ERC223Token is IERC223 {
  using SafeMath for uint;

  /**
   * @dev See `IERC223.totalSupply`.
   */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  mapping(address => uint) balances; // List of user balances.

  /**
   * @dev Transfer the specified amount of tokens to the specified address.
   *      Invokes the `tokenFallback` function if the recipient is a contract.
   *      The token transfer fails if the recipient is a contract
   *      but does not implement the `tokenFallback` function
   *      or the fallback function to receive funds.
   *
   * @param _to    Receiver address.
   * @param _value Amount of tokens that will be transferred.
   * @param _data  Transaction metadata.
   */
  function transfer(address _to, uint _value, bytes memory _data) public returns (bool success){
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if(Address.isContract(_to)) {
      IERC223Recipient receiver = IERC223Recipient(_to);
      receiver.tokenFallback(msg.sender, _value, _data);
    }
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  /**
   * @dev Transfer the specified amount of tokens to the specified address.
   *      This function works the same with the previous one
   *      but doesn't contain `_data` param.
   *      Added due to backwards compatibility reasons.
   *
   * @param _to    Receiver address.
   * @param _value Amount of tokens that will be transferred.
   */
  function transfer(address _to, uint _value) public returns (bool success){
    bytes memory empty = hex"00000000";
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if(Address.isContract(_to)) {
      IERC223Recipient receiver = IERC223Recipient(_to);
      receiver.tokenFallback(msg.sender, _value, empty);
    }
    emit Transfer(msg.sender, _to, _value, empty);
    return true;
  }


  /**
   * @dev Returns balance of the `_owner`.
   *
   * @param _owner   The address whose balance will be returned.
   * @return balance Balance of the `_owner`.
   */
  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

// File: contracts/tokens/ERC223Burnable.sol

pragma solidity ^0.5.4;


/**
 * @dev Extension of {ERC223} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC223Burnable is ERC223Token {
  /**
   * @dev Destroys `amount` tokens from the caller.
   *
   * See {ERC20-_burn}.
   */
  function burn(uint256 _amount) public {
    require(balanceOf(msg.sender) > _amount);
    _totalSupply = _totalSupply.sub(_amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    bytes memory empty = hex"00000000";
    emit Transfer(msg.sender, address(0), _amount, empty);
  }
}

// File: contracts/tokens/ERC223Mintable.sol

pragma solidity ^0.5.14;


/**
 * @dev Extension of {ERC223} that adds a set of accounts with the {MinterRole},
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC223Mintable is ERC223Token {

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  mapping(address => bool) public _minters;

  constructor () internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return _minters[account];
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    _minters[account] = true;
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    _minters[account] = false;
    emit MinterRemoved(account);
  }
  /**
   * @dev See {ERC20-_mint}.
   *
   * Requirements:
   *
   * - the caller must have the {MinterRole}.
   */
  function mint(address account, uint256 amount) public onlyMinter returns (bool) {
    balances[account] = balances[account].add(amount);
    _totalSupply = _totalSupply.add(amount);

    bytes memory empty = hex"00000000";
    emit Transfer(address(0), account, amount, empty);
    return true;
  }
}

// File: contracts/Migrations.sol

pragma solidity 0.5.14;

// This is needed by truffle framework
contract Migrations {
  address public owner;

  // A function with the signature `last_completed_migration()`, returning a uint, is required.
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  // A function with the signature `setCompleted(uint)` is required.
  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
