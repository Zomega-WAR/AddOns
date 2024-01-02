<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="RetAlert" version="2.0" date="19/06/2023">

    <Author name="Zomega" />

    <Dependencies>
      <Dependency name="EASystem_LayoutEditor" />
      <Dependency name="LibSlash" optional="false" />
    </Dependencies>

    <Description text="Be alerted when you are hit by a Slayer's Retribution ability." />

    <Files>
      <File name="Source\RetAlert.xml" />
      <File name="Source\RetAlert.lua" />
    </Files>

    <OnInitialize>
      <CallFunction name="RetAlert_OnInitialize" />
    </OnInitialize>

    <OnShutdown>
      <CallFunction name="RetAlert_OnShutdown" />
    </OnShutdown>

    <SavedVariables>
      <SavedVariable name="RetAlert_Settings" />
    </SavedVariables>   

    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="2.0" />

    <WARInfo>
      <Categories>
        <Category name="COMBAT" />
      </Categories>
    </WARInfo>

  </UiMod>
</ModuleFile>
