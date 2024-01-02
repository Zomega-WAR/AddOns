<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile>
    <UiMod name="Pocket Palette" version="1.15" date="24/11/2023" >
        
        <Author name="Eibon (creator), Zomega (maintainer)" email="" />

        <Description text="Pocket Palette inspired by DyePreview. Show the Pocket Palette window using the chat command /PP" />
        
        <VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.1" />

        <Dependencies>
            <Dependency name="EA_AbilitiesWindow" />
            <Dependency name="EA_CareerResourcesWindow" />
            <Dependency name="EA_MoraleWindow" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_Icons" />
            <Dependency name="EA_CharacterWindow" />
            <Dependency name="LibSlash" />
        </Dependencies>

        <Files>
            <File name="PocketPalette.lua" />
			      <File name="PocketPalette.xml" />
            <File name="PocketPalette.csv" />
        </Files>
        
        <OnInitialize>
            <CallFunction name="PP.Initialize" />
        </OnInitialize>

        <OnShutdown />
        <OnUpdate />

        <SavedVariables>
			<SavedVariable name="PP.settings.persistent" global="false" />
            <SavedVariable name="PP.settings.items" global="false" />
		</SavedVariables>

    </UiMod>
</ModuleFile>
