pragma solidity ^0.4.4;

import "@aragon/core/contracts/apps/App.sol";
import "@aragon/core/contracts/common/Initializable.sol";

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

contract Application is Initializable, App {
	  function initialize(string _name) onlyInit
		{
		    initialized();

				///
	  }
}
