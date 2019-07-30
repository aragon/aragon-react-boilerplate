pragma solidity 0.4.24;

import "@aragon/templates-shared/contracts/BaseTemplate.sol";

import "./CounterApp.sol";

// Using CompanyTemplate: https://github.com/aragon/dao-templates/tree/master/templates/company


contract Template is BaseTemplate {
    string constant private ERROR_MISSING_TOKEN_CACHE = "COMPANY_MISSING_TOKEN_CACHE";
    string constant private ERROR_EMPTY_HOLDERS = "COMPANY_EMPTY_HOLDERS";
    string constant private ERROR_BAD_HOLDERS_STAKES_LEN = "COMPANY_BAD_HOLDERS_STAKES_LEN";
    string constant private ERROR_BAD_VOTE_SETTINGS = "COMPANY_BAD_VOTE_SETTINGS";

    address constant ANY_ENTITY = address(-1);

    bool constant private TOKEN_TRANSFERABLE = true;
    uint8 constant private TOKEN_DECIMALS = uint8(18);
    uint256 constant private TOKEN_MAX_PER_ACCOUNT = uint256(0);            // no limit of tokens per account

    uint64 constant private DEFAULT_FINANCE_PERIOD = uint64(30 days);

    mapping (address => address) internal tokenCache;

    constructor(DAOFactory _daoFactory, ENS _ens, MiniMeTokenFactory _miniMeFactory, IFIFSResolvingRegistrar _aragonID)
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
        uint64 _financePeriod,
        bool _useAgentAsVault
    )
        external
    {
        newToken(_tokenName, _tokenSymbol);
        newInstance(_id, _holders, _stakes, _votingSettings, _financePeriod, _useAgentAsVault);
    }

    function newToken(string _name, string _symbol) public returns (MiniMeToken) {
        MiniMeToken token = _createToken(_name, _symbol, TOKEN_DECIMALS);
        _cacheToken(token, msg.sender);
        return token;
    }

    function newInstance(string _id, address[] _holders, uint256[] _stakes, uint64[3] _votingSettings, uint64 _financePeriod, bool _useAgentAsVault) public {
        require(_holders.length > 0, ERROR_EMPTY_HOLDERS);
        require(_holders.length == _stakes.length, ERROR_BAD_HOLDERS_STAKES_LEN);
        require(_votingSettings.length == 3, ERROR_BAD_VOTE_SETTINGS);
        MiniMeToken token = _popTokenCache(msg.sender);

        // Create DAO and install apps
        (Kernel dao, ACL acl) = _createDAO();
        Vault agentOrVault = _useAgentAsVault ? _installDefaultAgentApp(dao) : _installVaultApp(dao);
        Finance finance = _installFinanceApp(dao, agentOrVault, _financePeriod == 0 ? DEFAULT_FINANCE_PERIOD : _financePeriod);
        TokenManager tokenManager = _installTokenManagerApp(dao, token, TOKEN_TRANSFERABLE, TOKEN_MAX_PER_ACCOUNT);
        Voting voting = _installVotingApp(dao, token, _votingSettings[0], _votingSettings[1], _votingSettings[2]);

        // Install placeholder-app-name
        //--------------------------------------------------------------//
        bytes32 _appId = keccak256(abi.encodePacked(apmNamehash("open"), keccak256("placeholder-app-name")));
        CounterApp app = _installApp(_dao, _appId, new bytes(0), false);
        app.initialize();
        //--------------------------------------------------------------//

        // Mint tokens
        _mintTokens(acl, tokenManager, _holders, _stakes);

        _setupPermissions(dao, acl, agentOrVault, voting, finance, tokenManager, app, _useAgentAsVault);

        _registerID(_id, dao);
    }

    function _setupPermissions(Kernel _dao, ACL _acl, Vault _agentOrVault, Voting _voting, Finance _finance, TokenManager _tokenManager, CounterApp _app, bool _useAgentAsVault) internal {
        if (_useAgentAsVault) {
            _createAgentPermissions(_acl, Agent(_agentOrVault), _voting, _voting);
        }
        _createVaultPermissions(_acl, _agentOrVault, _finance, _voting);
        _createFinancePermissions(_acl, _finance, _voting, _voting);
        _createEvmScriptsRegistryPermissions(_acl, _voting, _voting);
        _createCustomVotingPermissions(_acl, _voting, _tokenManager);
        _createCustomTokenManagerPermissions(_acl, _tokenManager, _voting);

        // Setup placeholder-app-name permissions
        //--------------------------------------------------------------//
        _createCustomAppPermissions(_acl, _app, _voting);
        //--------------------------------------------------------------//

        _transferRootPermissionsFromTemplate(_dao, _voting);
    }

    function _createCustomVotingPermissions(ACL _acl, Voting _voting, TokenManager _tokenManager) internal {
        _acl.createPermission(_tokenManager, _voting, _voting.CREATE_VOTES_ROLE(), _voting);
        _acl.createPermission(_voting, _voting, _voting.MODIFY_QUORUM_ROLE(), _voting);
        _acl.createPermission(_voting, _voting, _voting.MODIFY_SUPPORT_ROLE(), _voting);
    }

    function _createCustomTokenManagerPermissions(ACL _acl, TokenManager _tokenManager, Voting _voting) internal {
        _acl.createPermission(_voting, _tokenManager, _tokenManager.BURN_ROLE(), _voting);
        _acl.createPermission(_voting, _tokenManager, _tokenManager.MINT_ROLE(), _voting);
    }

    function _createCustomAppPermissions(ACL _acl, CounterApp _app, Voting _voting) internal {
        _acl.createPermission(_voting, _app, _app.INCREMENT_ROLE(), _voting);
        _acl.createPermission(ANY_ENTITY, _app, _app.DECREMENT_ROLE(), _voting);
    }

    function _cacheToken(MiniMeToken _token, address _owner) internal {
        tokenCache[_owner] = _token;
    }

    function _popTokenCache(address _owner) internal returns (MiniMeToken) {
        require(tokenCache[_owner] != address(0), ERROR_MISSING_TOKEN_CACHE);

        MiniMeToken token = MiniMeToken(tokenCache[_owner]);
        delete tokenCache[_owner];
        return token;
    }
}
