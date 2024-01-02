<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="PlayEffectsOn" version="1.2" date="27/08/2021">

    <Author name="Zomega" />

    <Dependencies>
      <Dependency name="EA_ContextMenu" />
    </Dependencies>

    <Description text="A button to quickly and easily change the 'Play ability effects on' setting. Right click on the button to bring up the menu." />

    <Files>
      <File name="Source\PlayEffectsOn.xml" />
      <File name="Source\PlayEffectsOn.lua" />
    </Files>

    <OnInitialize>
      <CallFunction name="PlayEffectsOn.OnInitialize" />
    </OnInitialize>

    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

    <WARInfo>
      <Categories>
        <Category name="SYSTEM" />
      </Categories>
    </WARInfo>

  </UiMod>
</ModuleFile>
