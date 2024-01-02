function DisableCombatLog_OnInitialize ()

  TextLogSetEnabled ("Combat", false)

  TextLogAddEntry ("Chat", 0, L"<icon00057> DisableCombatLog addon: combat log is disabled.")

end
