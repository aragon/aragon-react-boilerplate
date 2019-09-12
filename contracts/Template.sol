pragma solidity 0.4.24;

import "@aragon/templates-shared/contracts/BaseTemplate.sol";

import "./CounterApp.sol";

contract Template is BaseTemplate {
    string constant private ERROR_MISSING_TOKEN_CACHE = "TEMPLATE_MISSING_TOKEN_CACHE";
    string constant private ERROR_EMPTY_HOLDERS = "TEMPLATE_EMPTY_HOLDERS";
    string constant private ERROR_BAD_HOLDERS_STAKES_LEN = "TEMPLATE_BAD_HOLDERS_STAKES_LEN";
    string constant private ERROR_BAD_VOTE_SETTINGS = "TEMPLATE_BAD_VOTE_SETTINGS";

    address constant private ANY_ENTITY = address(-1);
    bool constant private TOKEN_TRANSFERABLE = true;
    uint8 constant private TOKEN_DECIMALS = uint8(18);
    uint256 constant private TOKEN_MAX_PER_ACCOUNT = uint256(0);            // no limit of tokens per account

    mapping (address => address) internal tokenCache;

    constructor (
        DAOFactory _daoFactory,
        ENS _ens,
        MiniMeTokenFactory _miniMeFactory,
        IFIFSResolvingRegistrar _aragonID
    )
        BaseTemplate(_daoFactory, _ens, _miniMeFactory, _aragonID)
        public
    {
        _ensureAragonIdIsValid(_aragonID);
        _ensureMiniMeFactoryIsValid(_miniMeFactory);
    }

    function newTokenAndInstance(
        string _tokenName,
        string _tokenSymbol,
        string _id,
        address[] _holders,
        uint256[] _stakes,
        uint64[3] _votingSettings, /* supportRequired, minAcceptanceQuorum, voteDuration */
    )
        external
    {
        newToken(_tokenName, _tokenSymbol);
        newInstance(_id, _holders, _stakes, _votingSettings);
    }

    function newToken(string _name, string _symbol) public returns (MiniMeToken) {
        MiniMeToken token = _createToken(_name, _symbol, TOKEN_DECIMALS);
        _cacheToken(token, msg.sender);
        return token;
    }

    function newInstance(
        string _id,
        address[] _holders, 
        uint256[] _stakes,
        uint64[3] _votingSettings
    ) 
        public 
    {
        require(_holders.length > 0, ERROR_EMPTY_HOLDERS);
        require(_holders.length == _stakes.length, ERROR_BAD_HOLDERS_STAKES_LEN);
        require(_votingSettings.length == 3, ERROR_BAD_VOTE_SETTINGS);
        MiniMeToken token = _popTokenCache(msg.sender);
        // Create DAO and install apps
        (Kernel dao, ACL acl) = _createDAO();
        TokenManager tokenManager = _installTokenManagerApp(dao, token, TOKEN_TRANSFERABLE, TOKEN_MAX_PER_ACCOUNT);
        Voting voting = _installVotingApp(dao, token, _votingSettings[0], _votingSettings[1], _votingSettings[2]);
        // Install app
        CounterApp app = _installCounterApp(dao);
        // Mint tokens
        _mintTokens(acl, tokenManager, _holders, _stakes);
        _setupPermissions(dao, acl, voting, tokenManager, app);
        _registerID(_id, dao);
    }

    function _installCounterApp(
        Kernel _dao
    ) 
        internal returns (CounterApp) 
    {
        bytes32 _appId = keccak256(abi.encodePacked(apmNamehash("open"), keccak256("placeholder-app-name")));
        bytes memory initializeData = abi.encodeWithSelector(CounterApp(0).initialize.selector);
        CounterApp cunterApp = CounterApp(_installDefaultApp(_dao, _appId, initializeData))
        cunterApp.initialize();
        return cunterApp;
    }

    function _setupPermissions(
        Kernel _dao,
        ACL _acl,
        Voting _voting,
        TokenManager _tokenManager,
        CounterApp _app
    )
        internal 
    {
        _createEvmScriptsRegistryPermissions(_acl, _voting, _voting);
        _createCustomVotingPermissions(_acl, _voting, _tokenManager);
        _createCustomTokenManagerPermissions(_acl, _tokenManager, _voting);
        // Set app permission
        _createCustomAppPermissions(_acl, _app, _voting);
        _transferRootPermissionsFromTemplate(_dao, _voting);
    }

    function _createCustomVotingPermissions(
        ACL _acl,
        Voting _voting,
        TokenManager _tokenManager
    ) 
        internal
    {
        _acl.createPermission(_tokenManager, _voting, _voting.CREATE_VOTES_ROLE(), _voting);
        _acl.createPermission(_voting, _voting, _voting.MODIFY_QUORUM_ROLE(), _voting);
        _acl.createPermission(_voting, _voting, _voting.MODIFY_SUPPORT_ROLE(), _voting);
    }

    function _createCustomTokenManagerPermissions(
        ACL _acl,
        TokenManager _tokenManager,
        Voting _voting
    ) 
        internal 
    {
        _acl.createPermission(_voting, _tokenManager, _tokenManager.BURN_ROLE(), _voting);
        _acl.createPermission(_voting, _tokenManager, _tokenManager.MINT_ROLE(), _voting);
    }

    function _createCustomAppPermissions(
        ACL _acl,
        CounterApp _app,
        Voting _voting
    ) 
        internal
    {
        _acl.createPermission(_voting, _app, _app.INCREMENT_ROLE(), _voting);
        _acl.createPermission(ANY_ENTITY, _app, _app.DECREMENT_ROLE(), _voting);
    }

    function _cacheToken(
        MiniMeToken _token,
        address _owner
    ) 
        internal 
    {
        tokenCache[_owner] = _token;
    }

    function _popTokenCache(
        address _owner
    ) 
        internal returns (MiniMeToken) 
    {
        require(tokenCache[_owner] != address(0), ERROR_MISSING_TOKEN_CACHE);
        MiniMeToken token = MiniMeToken(tokenCache[_owner]);
        delete tokenCache[_owner];
        return token;
    }
}
