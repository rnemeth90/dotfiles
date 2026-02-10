$services = @("InMage PushInstall",
"InMage Scout Application Service",
"svagents",
"obengine",
"RecoveryServicesManagementAgent")

foreach ($service in $services) {
    Restart-Service -Name $service -Force
}