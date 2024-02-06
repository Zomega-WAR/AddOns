<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile>
  <UiMod name="AutoMark" version="1.0" date="06/02/2024">

    <Author name="Zomega (Omegus)"/>

    <Dependencies>
      <Dependency name="LibSlash" optional="false" />
    </Dependencies>

    <Description text="Automatically marks enemy targets with an icon that shows their career." />

    <Files>
      <File name="Textures\Textures.xml" />

      <File name="Source\AutoMark.xml" />
      <File name="Source\AutoMark.lua" />
    </Files>

    <OnInitialize>
      <CallFunction name="AutoMark.OnInitialize" />
    </OnInitialize>

    <OnUpdate>
      <CallFunction name="AutoMark.OnUpdate" />
    </OnUpdate>

    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

    <WARInfo>
      <Categories>
        <Category name="COMBAT" />
      </Categories>
    </WARInfo>

  </UiMod>
</ModuleFile>
