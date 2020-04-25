pragma solidity 0.5.14;

import "../tokens/IERC20.sol";
import "../library/SafeMath.sol";
import "../library/SignedSafeMath.sol";
import "../tokens/SToken.sol";
import "../tokens/Ownable.sol";

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
  IERC20 public collateralToken;
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
    collateralToken = IERC20(_collateralToken);
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
