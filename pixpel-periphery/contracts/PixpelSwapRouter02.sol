// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import './interfaces/IPixpelSwapFactory.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import './interfaces/IPixpelSwapRouter02.sol';
import './libraries/PixpelSwapLibrary.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';
import './interfaces/ILaunchpad.sol';

contract PixpelSwapRouter02 is IPixpelSwapRouter02 {
    using SafeMath for uint;
    address public immutable override factory;
    address public immutable override WETH;
    address public LAUNCHPAD;
    address public LPFUNDMANAGER;
    uint256 public SKALE_CHAIN_ID = 37084624;
    address public owner;
    mapping(address => bool) public isAllowedToken;
    //only for test
    // uint256 public chainIdOverride;
    event SkaleRouterConfigUpdated(uint256 newChainId);

    constructor(address _factory, address _WETH, address _LAUNCHPAD, address _LPFundManager) public {
        factory = _factory;
        WETH = _WETH;
        LAUNCHPAD = _LAUNCHPAD;
        LPFUNDMANAGER = _LPFundManager;
        owner = msg.sender;
    }

    receive() external payable {
        if (msg.sender != WETH) {
            revert('PixpelSwapRouter: Only WETH allowed');
        }
    }

    // ---- internal helpers replacing modifiers ----
    function _checkDeadline(uint deadline) internal view {
        require(deadline >= block.timestamp, 'PixpelSwapRouter: EXPIRED');
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, 'PixpelSwapRouter: FORBIDDEN');
    }

    function _onlyNonSkale() internal view {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        require(chainId != SKALE_CHAIN_ID, 'PixpelSwapRouter: SKALE network not supported');
    }

    // ---- internal helper for launchpad token restriction ----
    function _restrictLaunchpadTokens(address token) internal view {
        if (ILaunchpad(LAUNCHPAD).isTokenUsedInValidLaunchpad(token)) {
            require(msg.sender == LPFUNDMANAGER, 'Only fund manager can call when token is used');
        }
    }

    function _restrictLaunchpadTokens(address tokenA, address tokenB) internal view {
        if (
            ILaunchpad(LAUNCHPAD).isTokenUsedInValidLaunchpad(tokenA) ||
            ILaunchpad(LAUNCHPAD).isTokenUsedInValidLaunchpad(tokenB)
        ) {
            require(msg.sender == LPFUNDMANAGER, 'Only fund manager can call when token is used');
        }
    }

    //only for test
    // function setChainIdOverride(uint256 _id) external {
    //     chainIdOverride = _id;
    // }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IPixpelSwapFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IPixpelSwapFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = PixpelSwapLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = PixpelSwapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'PixpelSwapRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = PixpelSwapLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'PixpelSwapRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override returns (uint amountA, uint amountB, uint liquidity) {
        _checkDeadline(deadline);
        _restrictLaunchpadTokens(tokenA, tokenB);
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = PixpelSwapLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IPixpelSwapPair(pair).mint(to);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable virtual override returns (uint amountToken, uint amountETH, uint liquidity) {
        _checkDeadline(deadline);
        //only for test use this in other functions as well
        //     uint256 chainId;

        // assembly {
        //     chainId := chainid()
        // }
        // if (chainIdOverride != 0) {
        //     chainId = chainIdOverride;
        // }
        _onlyNonSkale();
        _restrictLaunchpadTokens(token);
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = PixpelSwapLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IPixpelSwapPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value.sub(amountETH));
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override returns (uint amountA, uint amountB) {
        _checkDeadline(deadline);
        _restrictLaunchpadTokens(tokenA, tokenB);
        address pair = PixpelSwapLibrary.pairFor(factory, tokenA, tokenB);
        IPixpelSwapPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IPixpelSwapPair(pair).burn(to);
        (address token0, ) = PixpelSwapLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'PixpelSwapRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'PixpelSwapRouter: INSUFFICIENT_B_AMOUNT');
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override returns (uint amountToken, uint amountETH) {
        _checkDeadline(deadline);
        _onlyNonSkale();
        _restrictLaunchpadTokens(token);
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = PixpelSwapLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IPixpelSwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        _onlyNonSkale();
        address pair = PixpelSwapLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IPixpelSwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override returns (uint amountETH) {
        _checkDeadline(deadline);
        _onlyNonSkale();
        (, amountETH) = removeLiquidity(token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint amountETH) {
        _onlyNonSkale();
        address pair = PixpelSwapLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IPixpelSwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PixpelSwapLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? PixpelSwapLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IPixpelSwapPair(PixpelSwapLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override returns (uint[] memory amounts) {
        _checkDeadline(deadline);
        _restrictLaunchpadTokens(path[0], path[1]);
        amounts = PixpelSwapLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PixpelSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PixpelSwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override returns (uint[] memory amounts) {
        _checkDeadline(deadline);
        _restrictLaunchpadTokens(path[0], path[1]);
        amounts = PixpelSwapLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'PixpelSwapRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PixpelSwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable virtual override returns (uint[] memory amounts) {
        _checkDeadline(deadline);
        _onlyNonSkale();
        _restrictLaunchpadTokens(path[0], path[1]);
        require(path[0] == WETH, 'PixpelSwapRouter: INVALID_PATH');
        amounts = PixpelSwapLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PixpelSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(PixpelSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override returns (uint[] memory amounts) {
        _checkDeadline(deadline);
        _onlyNonSkale();
        _restrictLaunchpadTokens(path[0], path[1]);
        require(path[path.length - 1] == WETH, 'PixpelSwapRouter: INVALID_PATH');
        amounts = PixpelSwapLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'PixpelSwapRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PixpelSwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override returns (uint[] memory amounts) {
        _checkDeadline(deadline);
        _onlyNonSkale();
        _restrictLaunchpadTokens(path[0], path[1]);
        require(path[path.length - 1] == WETH, 'PixpelSwapRouter: INVALID_PATH');
        amounts = PixpelSwapLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PixpelSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PixpelSwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable virtual override returns (uint[] memory amounts) {
        _checkDeadline(deadline);
        _onlyNonSkale();
        _restrictLaunchpadTokens(path[0], path[1]);
        require(path[0] == WETH, 'PixpelSwapRouter: INVALID_PATH');
        amounts = PixpelSwapLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'PixpelSwapRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(PixpelSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value.sub(amounts[0]));
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PixpelSwapLibrary.sortTokens(input, output);
            IPixpelSwapPair pair = IPixpelSwapPair(PixpelSwapLibrary.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = PixpelSwapLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? PixpelSwapLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override {
        _checkDeadline(deadline);
        _restrictLaunchpadTokens(path[0], path[1]);
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PixpelSwapLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'PixpelSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable virtual override {
        _checkDeadline(deadline);
        _onlyNonSkale();
        _restrictLaunchpadTokens(path[0], path[1]);
        require(path[0] == WETH, 'PixpelSwapRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(PixpelSwapLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'PixpelSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override {
        _checkDeadline(deadline);
        _onlyNonSkale();
        _restrictLaunchpadTokens(path[0], path[1]);
        require(path[path.length - 1] == WETH, 'PixpelSwapRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PixpelSwapLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'PixpelSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return PixpelSwapLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual override returns (uint amountOut) {
        return PixpelSwapLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual override returns (uint amountIn) {
        return PixpelSwapLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return PixpelSwapLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return PixpelSwapLibrary.getAmountsIn(factory, amountOut, path);
    }

    function setOwner(address _owner) external {
        _onlyOwner();
        require(_owner != address(0), 'PixpelSwapRouter: ZERO_ADDRESS');
        owner = _owner;
    }

    function setSkaleRouterConfig(uint256 _chainId) external {
        _onlyOwner();
        SKALE_CHAIN_ID = _chainId;
        emit SkaleRouterConfigUpdated(_chainId);
    }

    function updateLaunchpad(address _launchpad) external {
        _onlyOwner();
        require(_launchpad != address(0), 'PixpelSwapRouter: ZERO_ADDRESS');
        LAUNCHPAD = _launchpad;
    }
}
