<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile>

  <UiMod name="OverheadFonts" version="1.0" date="19/06/2024">

    <Author name="Zomega (Omegus)"/>

    <Description text="Allows you to change the font used to display the name, guild and title of players and NPCs over their head." />

    <Dependencies>        
      <Dependency name="EA_SettingsWindow" />
    </Dependencies>

    <Files>
      <File name="Source\OverheadFonts.lua" />
      <File name="Source\OverheadFonts.xml" />
    </Files>

    <OnInitialize>
      <CallFunction name="OverheadFonts.OnInitialize" />
    </OnInitialize>

    <SavedVariables>
      <SavedVariable name="OverheadFonts.SavedVariables" />
    </SavedVariables>

    </UiMod>
    
</ModuleFile>