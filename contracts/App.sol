pragma solidity ^0.4.4;

import "@aragon/core/contracts/apps/App.sol";
import "@aragon/core/contracts/common/Initializable.sol";

contract Application is Initializable, App {
	////
	////	           ....
	////	       .,,,,..,,,,.
	////	   ..,,.. ..     .,,,..
	////	 .,,.  ..,:....,,..  .,,.
	////	,:   ...,.    .,,..,.   :,
	////	.:. ,. ,           ,.. .:.
	////	 ,:,.  ..        .,,., :,
	////	  ,;.   ........,..,..:,
	////	   ,:.       .. .....:,
	////	    .:,           .::.
	////	      .,,.      .,,.
	////	        .,,,..,,,.
	////	           ....
	////
	////  Build something beautiful.
	function initialize(string _name) onlyInit
	{
		initialized();
	}
}
