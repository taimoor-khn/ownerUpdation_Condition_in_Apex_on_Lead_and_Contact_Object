public class ContactTriggerHandler {
    
    public static void updatingContactsOwner(List<Contact> conList) {
        System.debug('Inside updatingContactsOwner method of ContactTriggerHandler');
        Map<Contact, Id> conAccMap = new Map<Contact, Id>();
        Map<Id, Id> AccATMMap = new Map<Id, Id>();
        
        for (Contact con : conList) {
            conAccMap.put(con, con.AccountId);
        }
        
        List<AccountTeamMember> ATMList = [select Id, userId, AccountId, teamMemberRole from AccountTeamMember 
                                           where (accountId IN :conAccMap.Values() AND teamMemberRole = 'SDR' 
                                                  AND (Account.Account_Priority__c = 'Target Account' OR Account.Account_Priority__c = 'Focus'))];
        
        for (AccountTeamMember atm : ATMList) {
           AccATMMap.put(atm.accountId, atm.UserId);
        }
        for (Contact con : conList) {
            if (AccATMMap.keySet().contains(con.AccountId)) {
                con.OwnerId = AccATMMap.get(con.AccountId);
            }
        }
            
        
        
    }
    
    public static void assignContactToCompaign(List<Contact> conList, Map<Id, Contact> oldMap) {
        System.debug('Inside assignContactToCompaign method of ContactTriggerHandler');
        List<String> stringStatuses = new List<String>();
        List<Id> contactsAlreadyInsideCampaign = new List<Id>();
        List<CampaignMember> membersToBeInserted = new List<CampaignMember>();
        
        List<Marketing_Status_Value_For_Compaign__mdt> MStatuses = [select Label from Marketing_Status_Value_For_Compaign__mdt];
        List<CampaignMember> campaignMembers = [select Id, ContactId from campaignMember where campaignId = :System.Label.Campaign_ID];
        
        for (CampaignMember CM : campaignMembers) 
            contactsAlreadyInsideCampaign.add(CM.contactId);
        
        for (Marketing_Status_Value_For_Compaign__mdt MS : MStatuses)
            stringStatuses.add(MS.Label);
        System.debug('Campaign Id -> ' + System.Label.Campaign_ID);
        for (Contact con : conList) {
            if (oldMap == NULL) {
                System.debug('New Contact Inserted');
                if (stringStatuses.contains(con.Marketing_Status__c)) {
                    CampaignMember cm= New CampaignMember(CampaignId = System.Label.Campaign_ID, ContactId = con.Id, status='Sent');
                    membersToBeInserted.add(cm);
                }   
            }
            else if (con.Marketing_Status__c != oldMap.get(con.Id).Marketing_Status__c && !(contactsAlreadyInsideCampaign.contains(con.Id))) {
                System.debug('Contact Updated');
                if (stringStatuses.contains(con.Marketing_Status__c)) {
                    CampaignMember cm= New CampaignMember(CampaignId = System.Label.Campaign_ID, ContactId = con.Id, status='Sent');
                    membersToBeInserted.add(cm);
                }
            }     
        }
        if (membersToBeInserted.size() > 0)
        	insert membersToBeInserted;
        
    }
    
}