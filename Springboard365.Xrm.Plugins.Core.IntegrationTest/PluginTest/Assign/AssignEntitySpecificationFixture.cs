﻿namespace Springboard365.Xrm.Plugins.Core.IntegrationTest
{
    using System;
    using Microsoft.Crm.Sdk.Messages;
    using Microsoft.Xrm.Sdk;

    public class AssignEntitySpecificationFixture : SpecificationFixtureBase
    {
        public AssignRequest AssignRequest { get; private set; }

        public string MessageName { get; private set; }

        public void PerformTestSetup()
        {
            MessageName = "Assign";

            var targetEntity = new Entity("contact")
            {
                Id = Guid.NewGuid()
            };
            targetEntity["firstname"] = "DummyFirstName";
            OrganizationService.Create(targetEntity);
            
            AssignRequest = new AssignRequest
            {
                Target = targetEntity.ToEntityReference(),
                Assignee = CrmReader.GetSystemUser()
            };
        }
    }
}