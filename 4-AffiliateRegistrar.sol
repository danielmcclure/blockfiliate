contract AffiliateRegistrar {
    mapping(address => Affiliate) public affiliateContracts;
    address[] public affiliateContractsArray;

    address public owner;

    function AffiliateRegistrar() {
        owner = msg.sender;
    }

    function approveAffiliate(address _affiliateAddress) returns (bool) {
        // if (affiliateContracts[_affiliateAddress] != null) throw;
        Affiliate newAffiliate = new Affiliate(owner);
        affiliateContracts[_affiliateAddress] = newAffiliate;
        affiliateContractsArray.push(newAffiliate);

        return true;
    }
}

contract Affiliate {
    uint256 public affiliateVolume;
    
    address public owner;
    address public affiliateAddress;
    bytes public description;
    
    uint256[] public volumeThreshold;
    uint256[] public volumeAffiliatePercentage;
    
    function Affiliate(address _affiliateAddress) {
        owner = msg.sender;
        affiliateAddress = _affiliateAddress;
        volumeThreshold = [1,5,100,1000];
        volumeAffiliatePercentage = [1, 2, 3,5];
        description = "Affiliate fund description";
    }

   function getAffiliatePercentage() constant returns (uint) {
        for (uint i = 0; i < volumeThreshold.length; i++) {
            if (affiliateVolume < volumeThreshold[i]) return volumeAffiliatePercentage[i];
        }
        
        return volumeAffiliatePercentage[volumeThreshold.length - 1];
    }
    
   function pay() payable {
        affiliateVolume += msg.value;
        uint256 affiliateFee = msg.value * getAffiliatePercentage() / 100;
       
        if (!owner.send(msg.value - affiliateFee)) throw;
        if (!affiliateAddress.send(affiliateFee)) throw;
    }
}
