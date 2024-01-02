<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="DisableCombatLog" version="1.0" date="02/01/2024">

    <Author name="Zomega" />

    <Description text="Automatically disables the combat log." />

    <Files>
      <File name="DisableCombatLog.lua" />
    </Files>

    <OnInitialize>
      <CallFunction name="DisableCombatLog_OnInitialize" />
    </OnInitialize>

    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

    <WARInfo>
      <Categories>
        <Category name="CHAT" />
        <Category name="COMBAT" />
        <Category name="SYSTEM" />
      </Categories>
    </WARInfo>

  </UiMod>
</ModuleFile>
