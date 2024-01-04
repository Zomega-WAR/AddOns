<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <UiMod name="(DEMO) Line To Target" version="1.0" date="03/01/2024">

    <Author name="Zomega" />

    <Description text="Demonstration add-on that draws a scrolling line between the middle of the screen and the current friendly target." />

    <Files>
      <File name="Textures\Textures.xml" />
      <File name="Source\Line To Target.xml" />
      <File name="Source\Line To Target.lua" />
    </Files>

    <OnInitialize>
      <CallFunction name="LTT_OnInitialize" />
    </OnInitialize>

    <OnUpdate>
      <CallFunction name="LTT_OnUpdate" />
    </OnUpdate>

    <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" />

  </UiMod>
</ModuleFile>
