﻿namespace Springboard365.Xrm.Plugins.Core.Test
{
    using NUnit.Framework;
    using Springboard365.Xrm.UnitTest.Core;

    [TestFixture]
    public class WhenExecutingCloseQuotePluginSuccessfully : Specification<DummyCloseQuotePlugin>
    {
        protected override void Context()
        {
            TestFixture = new CloseQuotePluginSpecificationFixture();
            TestFixture.PerformTestSetup();
        }

        protected override void BecauseOf()
        {
            TestFixture.UnderTest.Execute(TestFixture.ServiceProvider.Object);
        }

        [Test]
        public void OrganizationServiceShouldNotBeNull()
        {
            Assert.IsNotNull(TestFixture.UnderTest.OrganizationService);
        }

        [Test]
        public void PluginExecutionContextShouldNotBeNull()
        {
            Assert.IsNotNull(TestFixture.UnderTest.PluginExecutionContext);
        }

        [Test]
        public void TracingServiceShouldNotBeNull()
        {
            Assert.IsNotNull(TestFixture.UnderTest.TracingService);
        }

        [Test]
        public void QuoteCloseShouldNotBeNull()
        {
            Assert.IsNotNull(TestFixture.UnderTest.QuoteClose);
        }

        [Test]
        public void StatusShouldNotBeNull()
        {
            Assert.IsNotNull(TestFixture.UnderTest.Status);
        }
    }
}