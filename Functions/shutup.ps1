function teams {
  Start-Process "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe"
}
function teamsk {
  elevateProcess taskkill.exe "/IM Teams.exe /F"
  Clear-Host
}

function mail {
  Start-Process "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"
}
function mailk {
  elevateProcess taskkill.exe "/IM OUTLOOK.EXE /F"
  Clear-Host
}
