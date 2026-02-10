Workflow stop-start-vm-by-rg
{ 
    Param 
    (    
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String] 
        $AzureSubscriptionId, 
        [Parameter(Mandatory=$true)][ValidateSet("Start","Stop")] 
        [String] 
        $Action,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
        [String] 
        $ResourceGroupName
    ) 
     
    #Globals
    $credential = Get-AutomationPSCredential -Name 'ryanadmin'
    Login-AzureRmAccount -Credential $credential 
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId 
    $AzureVMList = Get-AzureRmResourceGroup -ResourceGroupName $ResourceGroupName | Get-AzureRmVm 

    
    function sendMail{

        # Parameter help description
        param(
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [String]
            $Sender,
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [String]
            $Recipient,
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [String]
            $Server,
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [String]
            $Subject,
            [Parameter(Mandatory=$false)]
            [String]
            $Body,
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [String]
            $Username,
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [SecureString]
            $Password,
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
            [Bool]
            $UseSSL
        )
        
        $SMTPMessage = New-Object System.Net.Mail.MailMessage($Sender,$Recipient,$Subject,$Body)
        $SMTPClient = New-Object Net.Mail.SmtpClient($Server, 587) 
        $SMTPClient.EnableSsl = $UseSSL 
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Username,$Password); 
        $SMTPClient.Send($SMTPMessage)
    }

    foreach($AzureVM in $AzureVMList) 
    { 
        if(!(Get-AzureRmVM | Where-Object {$_.Name -eq ($AzureVM).Name})) 
        { 
            throw " AzureVM : [$AzureVM] - Does not exist! - Check your inputs " 
        } 
    } 
 
    if($Action -eq "Stop") 
    { 
        Write-Output "Stopping VMs"; 
        foreach -parallel ($AzureVM in $AzureVMList) 
        { 
            Get-AzureRmVM | Where-Object {$_.Name -eq ($AzureVM).Name} | Stop-AzureRmVM -Force 
        } 
    }
    else 
    { 
        Write-Output "Starting VMs"; 
        foreach -parallel ($AzureVM in $AzureVMsToHandle) 
        { 
            Get-AzureRmVM | Where-Object {$_.Name -eq ($AzureVM).Name} | Start-AzureRmVM 
        } 
    } 
}