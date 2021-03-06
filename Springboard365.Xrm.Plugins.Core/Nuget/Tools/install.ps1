param($installPath, $toolsPath, $package, $project)
    if($project -eq $null) {
        $project = Get-Project
    }

    $assemblyKeyFileName = Springboard365Private-CopyAssemblyKeyToOutputDirectory($project)
    Springboard365Private-AddILMergePropertyToReferences($project)	
    $project.Save()

    Add-Type -AssemblyName 'Microsoft.Build, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
    $msbuild = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($project.FullName) | Select-Object -First 1
 
    $projectUri = New-Object Uri($project.FullName, [System.UriKind]::Absolute)
    $targetsFile = [System.IO.Path]::Combine($toolsPath, $package.Id + '.targets')
    $targetUri = New-Object Uri($targetsFile, [System.UriKind]::Absolute)
    $relativePath = [System.Uri]::UnescapeDataString($projectUri.MakeRelativeUri($targetUri).ToString()).Replace([System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)

    $ILMergeFileLocation = [System.IO.Path]::Combine($toolsPath, 'ILMerge.exe')
    $ILMergeFileLocationUri = New-Object Uri($ILMergeFileLocation, [System.UriKind]::Absolute)
    $ILMergeFileLocationRelativePath = [System.Uri]::UnescapeDataString($projectUri.MakeRelativeUri($ILMergeFileLocationUri).ToString()).Replace([System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)
 
    $import = $msbuild.Xml.AddImport($relativePath)
    $import.Condition = "Exists('$relativePath')"
    
    $targetFramework = """v4," + $env:ProgramFiles + "\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0"""

    $target = $msbuild.Xml.AddTarget("Springboard365AfterBuild")
    $target.AfterTargets = "AfterBuild"

    $project.Save()

    $commandText = """$ILMergeFileLocationRelativePath"" /targetplatform:$targetFramework /keyfile:$assemblyKeyFileName `$(AdditionalParameters) /out:""`$(OutputFileName)"" ""`$(MainAssembly)"" @(AssembliesToMerge->'""`$(TargetDir)%(AssemblyName)""', ' ')"
    $task = $target.AddTask("Exec")
    $task.SetParameter("Command", $commandText)

    $message = $target.AddTask("Message")
    $message.SetParameter("Text", $commandText)
    $message.SetParameter("Importance", "High")

    $project.Save()

    $xml = [XML] (gc $project.FullName)
    $nsmgr = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xml.NameTable
    $nsmgr.AddNamespace('msbld', "http://schemas.microsoft.com/developer/msbuild/2003")

    $node = $xml.Project.SelectSingleNode("//msbld:Target[@Name='Springboard365AfterBuild']", $nsmgr)
    $afterBuildExecuteScript = $node.InnerXml

    $fileRetrieval = $xml.CreateElement("FileRetrieval", $xml.Project.GetAttribute("xmlns"))
    $itemGroup = $xml.CreateElement("ItemGroup", $xml.Project.GetAttribute("xmlns"))
    $assembliesToMerge = $xml.CreateElement("AssembliesToMerge", $xml.Project.GetAttribute("xmlns"))
    $itemGroup.AppendChild($assembliesToMerge)
    $fileRetrieval.AppendChild($itemGroup)

    $includeAttribute = $xml.CreateAttribute("Include")
    $includeAttribute.Value = "@(ReferencePath)"
    $assembliesToMerge.Attributes.Append($includeAttribute)

    $conditionAttribute = $xml.CreateAttribute("Condition")
    $conditionAttribute.Value = "'%(ReferencePath.ILMerge)'=='true'"
    $assembliesToMerge.Attributes.Append($conditionAttribute)

    $node.InnerXml = $fileRetrieval.InnerXml + $afterBuildExecuteScript
    
    $xml.Save($project.FullName)

    $project.Save()
    
    #$dte.ItemOperations.Navigate("https://www.springboard365.com", $dte.vsNavigateOptions.vsNavigateOptionsNewWindow)