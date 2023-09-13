@isTest
public class ContactTriggerHandlerTest {

    @testSetup
    static void setup() {
        
        UserRole role1 = new UserRole(DeveloperName = 'TestRoleForAccount', Name = 'SDR');
        insert role1;
        
        User testUser1 = new User(
            LastName = 'Test User',
            Alias = 'TestUser',
            Email = 'testuser1@gmail.com',
            Username = 'testuser_1@gmail.com',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            IsActive = true,
            UserRoleID = role1.Id
        );        
        insert testUser1;
    }
    
    @isTest
    static void checkIfContactOwnerChanges() {
        
        Test.StartTest();
        User user1 = [select Id, Alias from User where Alias = 'TestUser' LIMIT 1];
        
        Account acc = new Account();
        acc.Name = 'Test Account For Contact';
        acc.Account_Priority__c = 'Target Account';
        insert acc;
       
        AccountTeamMember ATM = new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'SDR', UserId = user1.Id);
        insert ATM;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        con.Marketing_Status__c = 'Prospect';
        insert con;
        
        Contact con2 = [select Id, LastName, OwnerId from Contact where lastName = 'Test Contact' LIMIT 1];
        Account acc2 = [select Id, Name, OwnerId from Account where Name = 'Test Account For Contact' LIMIT 1];
        AccountTeamMember atm2 = [select UserId from AccountTeamMember where AccountId = :acc2.Id LIMIT 1];
        Test.StopTest();
        //System.debug('Con -> ' + con2.OwnerId + ', Account -> ' + acc2.OwnerId + ', ATM -> ' + atm2.UserId);
        System.assertEquals(con2.OwnerId, atm2.UserId);
    }
    
    @isTest
    static void checkIfContactOwnerChanges2() {
        
        Test.StartTest();
        User user1 = [select Id, Alias from User where Alias = 'TestUser' LIMIT 1];
        
        Account acc = new Account();
        acc.Name = 'Test Account For Contact';
        acc.Account_Priority__c = 'Target Account';
        insert acc;
       
        AccountTeamMember ATM = new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'Account Manager', UserId = user1.Id);
        insert ATM;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        con.Marketing_Status__c = 'Prospect';
        insert con;
        
        Contact con2 = [select Id, LastName, OwnerId from Contact where lastName = 'Test Contact' LIMIT 1];
        Account acc2 = [select Id, Name, OwnerId from Account where Name = 'Test Account For Contact' LIMIT 1];
        AccountTeamMember atm2 = [select UserId from AccountTeamMember where AccountId = :acc2.Id LIMIT 1];
        Test.StopTest();
        //System.debug('Con -> ' + con2.OwnerId + ', Account -> ' + acc2.OwnerId + ', ATM -> ' + atm2.UserId);
        System.assertNotEquals(con2.OwnerId, atm2.UserId);
    }
    
    @isTest
    static void addingContactToCampaignInsert() {
        
        Test.StartTest();
        User user1 = [select Id, Alias from User where Alias = 'TestUser' LIMIT 1];
        
        Account acc = new Account();
        acc.Name = 'Test Account For Contact';
        acc.Account_Priority__c = 'Target Account';
        insert acc;
       
        AccountTeamMember ATM = new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'SDR', UserId = user1.Id);
        insert ATM;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        con.Marketing_Status__c = 'Sales Prospect Lead (SPL)';
        insert con;
        
        Contact con2 = [select Id, LastName, OwnerId from Contact where lastName = 'Test Contact' LIMIT 1];
        con2.Marketing_Status__c = 'Sales Prospect Lead (SPL)';
        update con2;
        
        Account acc2 = [select Id, Name, OwnerId from Account where Name = 'Test Account For Contact' LIMIT 1];
        AccountTeamMember atm2 = [select UserId from AccountTeamMember where AccountId = :acc2.Id LIMIT 1];
        List<CampaignMember> campaignMembers = [select Id, ContactId from campaignMember where campaignId = :System.Label.Campaign_ID AND contactId = :con2.Id];
        Test.StopTest();
        //System.debug('Con -> ' + con2.OwnerId + ', Account -> ' + acc2.OwnerId + ', ATM -> ' + atm2.UserId);
        System.assertEquals(con2.OwnerId, atm2.UserId);
        System.assertEquals(1, campaignMembers.Size());
    }
    
    @isTest 
    static void addingContactToCampaignUpdate() {
        
        Test.StartTest();
        User user1 = [select Id, Alias from User where Alias = 'TestUser' LIMIT 1];
        
        Account acc = new Account();
        acc.Name = 'Test Account For Contact';
        acc.Account_Priority__c = 'Target Account';
        insert acc;
       
        AccountTeamMember ATM = new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'Account Manager', UserId = user1.Id);
        insert ATM;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        con.Marketing_Status__c = 'Prospect';
        insert con;
        
        List<CampaignMember> campaignMembers = [select Id, ContactId from campaignMember where campaignId = :System.Label.Campaign_ID AND contactId = :con.Id];
        System.assertEquals(0, campaignMembers.Size());
        
        Contact con2 = [select Id, LastName, OwnerId from Contact where lastName = 'Test Contact' LIMIT 1];
        con2.Marketing_Status__c = 'Sales Prospect Lead (SPL)';
        update con2;
        
        Account acc2 = [select Id, Name, OwnerId from Account where Name = 'Test Account For Contact' LIMIT 1];
        AccountTeamMember atm2 = [select UserId from AccountTeamMember where AccountId = :acc2.Id LIMIT 1];
        campaignMembers = [select Id, ContactId from campaignMember where campaignId = :System.Label.Campaign_ID AND contactId = :con2.Id];
        Test.StopTest();
        //System.debug('Con -> ' + con2.OwnerId + ', Account -> ' + acc2.OwnerId + ', ATM -> ' + atm2.UserId);
        System.assertNotEquals(con2.OwnerId, atm2.UserId);
        System.assertEquals(1, campaignMembers.Size());
    }
    
}