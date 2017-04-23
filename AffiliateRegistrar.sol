pragma solidity ^0.4.8;

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
    mapping(address => uint256) public affiliateVolume;
    mapping(address => uint256) public affiliateFunds;
    
    address public owner;
    address public registrar;
    address[] public affiliates;
    bytes public description;
    
    uint256[] volumeThreshold;
    uint256[] volumeAffiliatePercentage;
    
   function Affiliate(address _owner) {
        registrar = msg.sender;
        owner = _owner;
        volumeThreshold = [1,10,100,1000];
        volumeAffiliatePercentage = [1, 2, 3,5];
        description = "Affiliate fund description";
    }

   function getAffiliatePercentage(address affiliateAddress) constant returns (uint) {
        uint256 volume = affiliateVolume[affiliateAddress];
        
       for (uint i = 0; i < volumeThreshold.length; i++) {
            if (volume >= volumeThreshold[i]) return volumeAffiliatePercentage[i];
        }
        
       return volumeAffiliatePercentage[0]; //TODO should value be 0?
    }
    
   function acceptPayment(address affiliateAddress) payable returns (bool){
       affiliateVolume[affiliateAddress] += msg.value;

       uint256 affiliateFee = msg.value * getAffiliatePercentage(affiliateAddress) / 100;
       // affiliateFunds[affiliateAddress] += affiliateFee;
        
       owner.send(msg.value - affiliateFee);
        
       //TODO add time delay
       affiliateAddress.send(affiliateFee);
       // affiliateFunds[affiliateAddress] = 0;
        
       return true;
    }
    
   function getAffiliateVolume() constant returns (uint256[]) {
        uint256[] memory affiliateVolumeResult = new uint256[](affiliates.length);
        
       for (uint i = 0; i < affiliates.length; i++) {
            affiliateVolumeResult[i] = affiliateVolume[affiliates[i]];
        }
        
       return (affiliateVolumeResult);
    }
}
