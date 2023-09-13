@isTest(SeeAllData=false)
private class AssignLeadsRoundRobinClassTest {
    
    @testSetup static void setupUsers() {
        // Create test data - one active SDR user and three new leads
        
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole', Name = 'SDR');
        insert r1;
        UserRole r2 = new UserRole(DeveloperName = 'My', Name = 'SDR');
        insert r2;
        User testUser = new User(
            FirstName = 'SDR',
            LastName = ' b',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            Username = 'testuser_swim@test.com',
            CommunityNickname = 'testuser',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            IsActive = true,
            UserRoleID = r1.ID
        );
        insert testUser;
        User testUser2 = new User(
            FirstName = 'Cat',
            LastName = 'Don',
            Email = 'testuser2@test.com',
            Alias = 'tuser2',
            Username = 'testuser_swim2@test.com',
            CommunityNickname = 'testuser2',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            IsActive = true,
            UserRoleID = r2.ID
        );
        insert testUser2;
        
        
        
    }
    
    @isTest static void caseInsertion1() {
        list<User> u=[select id,Name from user where FirstName='SDR' limit 1];
        Test.startTest();
        Account acc=new Account();
        acc.Name='Testing';
        acc.Account_Priority__c='Target Account';
        acc.website='www.Testingupdation.com';
        insert acc;
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = acc.ID,
                                                          TeamMemberRole = 'SDR',UserId = u[0].ID);
        insert newTeam;
        //system.debug(newTeam);
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'SF Lead';
        led.Email = 'Testing@updation.com';
        led.Company = 'Testing';
        led.Industry = 'Agriculture';
        led.website = 'www.Testingupdation.com';
        led.Status = 'Open';
        led.Marketing_Status__c='Sales Qualified Lead';
        
        //led.CreatedById=u[0].ID;
        insert led;
        //system.debug(led.OwnerId);
        Test.stopTest();
        list<lead> lList=[select id,ownerid from lead where FirstName='Test' limit 1];
        Assert.areEqual(newTeam.UserId,lList[0].OwnerId);
    }
    @isTest static void caseInsertion2() {
        list<User> u=[select id,Name from user where FirstName='Cat' limit 1];
        Test.startTest();
        Account acc=new Account();
        acc.Name='Testing';
        acc.Account_Priority__c='Target Account';
        acc.website='www.Testingupdation.com';
        insert acc;
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = acc.ID,
                                                          TeamMemberRole = 'TESTING',UserId = u[0].ID);
        insert newTeam;
        // system.debug(newTeam);
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'SF Lead';
        led.Email = 'Testing@updation.com';
        led.Company = 'Testing';
        led.Industry = 'Agriculture';
        led.website = 'www.Testingupdation.com';
        led.Status = 'Open';
        led.Marketing_Status__c='Sales Qualified Lead';
        
        insert led;
        // system.debug(led.OwnerId);
        Test.stopTest();
        list<lead> lList=[select id,ownerid from lead where FirstName='Test' limit 1];
        Assert.areNotEqual(newTeam.UserId,lList[0].OwnerId);
    }
    @isTest static void funUpdation() {
        list<User> u=[select id,Name from user where FirstName='SDR' limit 1];
        Test.startTest();
        Account acc=new Account();
        acc.Name='Testingupdation';
        acc.Account_Priority__c='Target Account';
        acc.website='www.Testingupdation.com';
        insert acc;
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = acc.ID,
                                                          TeamMemberRole = 'SDR',UserId = u[0].ID);
        insert newTeam;
        Lead led = new Lead();
        led.FirstName = 'Test1';
        led.LastName = 'SF Lead';
        led.Email = 'Testing@updation.com';
        led.website = 'www.Testingupdation.com';
        led.company = 'Tes';
        led.Industry = 'Agriculture';
        led.Status = 'Open';
        led.Marketing_Status__c='Sal';
        
        insert led; 
        list<lead> leadList=[select id,website,Marketing_Status__c from lead where id=:led.id];
        list<lead> newLeadList=new list<lead> ();
        // system.debug(leadList);
        for(lead obj:leadList)
        {
            obj.Marketing_Status__c='Marketing Qualified Lead';
            newLeadList.add(obj);
        }
        upsert newLeadList;
        list<lead> lList=[select id,ownerid,Marketing_Status__c from lead where FirstName='Test1' limit 1];
        list<CampaignMember> cmList=[select Id, leadId, campaignId from CampaignMember where leadId =: lList[0].Id ];
        Assert.areEqual(1,cmList.size());
        Test.stopTest();
    }
    @isTest static void caseInsertionsamename() {
        list<User> u=[select id,Name from user where FirstName='SDR' limit 1];
        Test.startTest();
        Account acc=new Account();
        acc.Name='Testingupdation';
        acc.Account_Priority__c='Target Account';
        acc.website='www.Testingupdation.com';
        insert acc;
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = acc.ID,
                                                          TeamMemberRole = 'SDR',UserId = u[0].ID);
        insert newTeam;
        Lead led = new Lead();
        led.FirstName = 'Test1';
        led.LastName = 'SF Lead';
        led.Email = 'Testing@updation.com';
        led.website = 'www.Testingupdation.com';
        led.company = 'Testingupdation';
        led.Industry = 'Agriculture';
        led.Status = 'Open';
        led.Marketing_Status__c='Sal';
        insert led; 
        Lead ledq = new Lead();
        ledq.FirstName = 'Test1i';
        ledq.LastName = 'SF Lead';
        ledq.Email = 'Testing@oupdation.com';
        ledq.website = 'www.Testinguupdation.com';
        ledq.company = 'Testingupdation';
        ledq.Industry = 'Agriculture';
        ledq.Status = 'Open';
        ledq.Marketing_Status__c='Sal';
        insert ledq; 
        list<lead> leadList=[select id,website,Marketing_Status__c from lead where id=:led.id];
        list<lead> newLeadList=new list<lead> ();
        // system.debug(leadList);
        for(lead obj:leadList)
        {
            obj.Marketing_Status__c='Marketing Qualified Lead';
            newLeadList.add(obj);
        }
        upsert newLeadList;
        list<lead> lList=[select id,ownerid,Marketing_Status__c from lead where FirstName='Test1' limit 1];
        list<CampaignMember> cmList=[select Id, leadId, campaignId from CampaignMember where leadId =: lList[0].Id ];
        Assert.areEqual(1,cmList.size());
        Test.stopTest();
    }
}