﻿namespace Springboard365.Xrm.Plugins.Core
{
    using System;
    using Microsoft.Xrm.Sdk;
    using Springboard365.Xrm.Plugins.Core.Constants;
    using Springboard365.Xrm.Plugins.Core.Extensions;
    using Springboard365.Xrm.Plugins.Core.Framework;

    public abstract class AddToQueuePlugin : Plugin
    {
        protected override void Execute(
            IOrganizationService organizationService,
            IPluginExecutionContext pluginExecutionContext,
            ITracingService tracingService)
        {
            var target = pluginExecutionContext.InputParameters.GetParameter<EntityReference>(InputParameterType.Target);
            var destinationQueueId = pluginExecutionContext.InputParameters.GetParameter<Guid>(InputParameterType.DestinationQueueId);
            var sourceQueueId = pluginExecutionContext.InputParameters.GetParameter<Guid>(InputParameterType.SourceQueueId);

            Execute(organizationService, pluginExecutionContext, tracingService, target, destinationQueueId, sourceQueueId);
        }

        protected abstract void Execute(
            IOrganizationService organizationService,
            IPluginExecutionContext pluginExecutionContext,
            ITracingService tracingService,
            EntityReference target,
            Guid destinationQueueId,
            Guid sourceQueueId);
    }
}