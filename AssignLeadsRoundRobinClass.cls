public class AssignLeadsRoundRobinClass {
    
    public static void assignLeadsRoundRobin(List<Lead> newLeads) {
        boolean excludeLead = false;
        
        List<User> Users = [SELECT Id FROM User WHERE (UserRole.Name = 'SDR' AND Id = :System.UserInfo.getUserId())];
        if(users.size() > 0)
        {
            excludeLead=true; 
        }
        // Assign each new lead to the next active user in the round-robin sequence
        Integer lastAssignedUserIndex = 0;
        List<User> activeUsers = [SELECT Id FROM User WHERE IsActive = true AND UserRole.Name = 'SDR' ORDER BY Name ASC];
        
        for (Lead lead : newLeads) {
            // Check if the lead source is "ZoomInfo" or "Sales" and exclude the lead
            if (lead.LeadSource != 'ZoomInfo' && lead.LeadSource != 'Sales' && !(excludeLead)) {
                // Find the next active user who is not excluded
                lastAssignedUserIndex = Math.mod((lastAssignedUserIndex + 1), activeUsers.size());
                lead.OwnerId = activeUsers[lastAssignedUserIndex].Id;
            }
            
        }
    }
 
    public static void assignUserLead(List<Lead> newLeads) {
        
        Map<String, lead> mapAccLead = new Map<String, lead>();
        list<String> leadMapCo = new  list<String>();
        list<String> leadMapWo = new   list<String>();
        list<String> leadMapEd = new  list<String>();
        Map<String, list<lead>> leadMapColist = new  Map<String, list<lead>>();
        Map<String, list<lead>> leadMapWoobjlist = new   Map<String, list<lead>>();
        Map<String, list<lead>>leadMapEdobjlist = new   Map<String, list<lead>>();
        for(lead obj:newLeads)
        {
            if (obj.Company != '' && obj.Company != null)
            {
                leadMapCo.add(obj.Company);
                if(leadMapColist.containsKey(obj.Company)){
                    leadMapColist.get(obj.Company).add(obj);
                } else {
                    leadMapColist.put(obj.Company, new List<lead>{obj});
                }
            }
            if (obj.website_domain__c != '' && obj.website_domain__c != null)    
            {
                leadMapWo.add(obj.website_domain__c);
                if(leadMapWoobjlist.containsKey(obj.website_domain__c)){
                    leadMapWoobjlist.get(obj.website_domain__c).add(obj);
                } else {
                    leadMapWoobjlist.put(obj.website_domain__c, new List<lead>{obj});
                }
            }
            if (obj.email_domain__c != '' && obj.email_domain__c != null)    
            {
                leadMapEd.add(obj.email_domain__c);
                if(leadMapEdobjlist.containsKey(obj.email_domain__c)){
                    leadMapEdobjlist.get(obj.email_domain__c).add(obj);
                } else {
                    leadMapEdobjlist.put(obj.email_domain__c, new List<lead>{obj});
                }
            }     
        }
        List<AccountTeamMember> accTM=[select id,UserId ,accountId,account.website_Domain__c,account.name,account.Account_Priority__c ,TeamMemberRole from AccountTeamMember where ((account.Account_Priority__c='Target Account' OR account.Account_Priority__c='Focus')and (account.name in: leadMapCo OR account.website_Domain__c in: leadMapEd OR account.website_Domain__c in: leadMapWo)  and TeamMemberRole='SDR')];
        system.debug('->>>>>>>>>>>>>>>>>>>>>>>'+accTM);
        for(AccountTeamMember obj:accTM)
        {
            if(leadMapColist.containsKey(obj.account.name))
            {
                for(lead lObj :leadMapColist.get(obj.account.name))
                {
                    lObj.OwnerId=obj.UserId;
                }
            }
            if(leadMapWoobjlist.containsKey(obj.account.website_Domain__c))
            {
                for(lead lObj :leadMapWoobjlist.get(obj.account.website_Domain__c))
                {
                    lObj.OwnerId=obj.UserId;
                }
            }
            if(leadMapEdobjlist.containsKey(obj.account.website_Domain__c))
            {
                for(lead lObj :leadMapEdobjlist.get(obj.account.website_Domain__c))
                {
                    lObj.OwnerId=obj.UserId;
                }
            }
        }
        
    }
    public static void assignCampaign(List<Lead> newLead, Map<Id, Lead> oldMap) {
        List<Marketing_Status_Value_For_Compaign__mdt> metaData = Marketing_Status_Value_For_Compaign__mdt.getall().values();
        // system.debug(metaData);
        list<string>labelList =new list<string>();
        List<Id> leadAlreadyInsideCampaign = new List<Id>();
        for(Marketing_Status_Value_For_Compaign__mdt obj:metaData)
        {
            labelList.add(obj.label);
        }
        // system.debug(labelList);
        List<CampaignMember> campaignMembers = [select Id, leadId from campaignMember where campaignId = :System.Label.Campaign_ID];
        // system.debug(campaignMembers);
        for (CampaignMember CM : campaignMembers) 
            leadAlreadyInsideCampaign.add(CM.leadId);
        
        list<CampaignMember> newCampaignMember= new list<CampaignMember>();
        for(lead objLead:newLead)
        {
            system.debug(labelList.contains(objLead.Marketing_Status__c));
            if (oldMap == null) {
                //   System.debug('New Lead Inserted');
                if (labelList.contains(objLead.Marketing_Status__c)) {
                    CampaignMember newMember= New CampaignMember(LeadId = objLead.id, status='Sent', campaignid =  System.Label.Campaign_ID);
                    newCampaignMember.add(newMember);
                }   
            }
            else if(objLead.Marketing_Status__c != oldMap.get(objLead.Id).Marketing_Status__c && !(leadAlreadyInsideCampaign.contains(objLead.Id))&& labelList.contains(objLead.Marketing_Status__c)  )
            {
                CampaignMember newMember = new CampaignMember(LeadId = objLead.id, status='Sent', campaignid =  System.Label.Campaign_ID);
                newCampaignMember.add(newMember);
            }
        }
        upsert newCampaignMember;
    }
}

/* OLD CODE */
/* public class AssignLeadsRoundRobinClass {
public static void assignLeadsRoundRobin(List<Lead> leads) {
// Get a list of all active users
List<User> activeUsers = [SELECT Id, Name FROM User WHERE IsActive = true AND UserRole.Name = 'SDR' ORDER BY Name ASC];

// Get the index of the last user who was assigned a lead
Integer lastAssignedUserIndex = 0;
List<Lead> existingLeads = [SELECT OwnerId FROM Lead WHERE OwnerId IN :activeUsers AND IsConverted = false ORDER BY CreatedDate DESC LIMIT 1];
if (!existingLeads.isEmpty()) {
for (User u : activeUsers) {
if (u.Id == existingLeads[0].OwnerId) {
break;          
} else {
lastAssignedUserIndex++;
}
}
}

// Assign each new lead to the next active user in the round-robin sequence
for (Lead lead : leads) {
lastAssignedUserIndex = Math.mod((lastAssignedUserIndex + 1), activeUsers.size());
lead.OwnerId = activeUsers[lastAssignedUserIndex].Id;
}
}
} */