#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -Version 3.0

Function GetVPNConnectionInfos
{
    $LocalVPNConnections = Get-VpnConnection | Select Name,ServerAddress,TunnelType,AllUserConnection
    $GlobalVPNConnections = Get-VpnConnection -AllUserConnection | Select Name,ServerAddress,TunnelType,AllUserConnection
    $SumVPNConnections = [Array]$LocalVPNConnections + [Array]$GlobalVPNConnections
    
    #Define a initial number
    $ID = 0
    Foreach($VPNConnections in $SumVPNConnections)
    {
        $ID++
        $Objs = [PSCustomObject]@{ ID = $ID
                                   Name = $VPNConnections.Name                     
                                   ServerAddress = $VPNConnections.ServerAddress
                                   TunnelType = $VPNConnections.TunnelType
                                   AllUserConnection = $VPNConnections.AllUserConnection 
                                 }
        $Objs
    }
    
}

Function Remove-OSCVPNConnection
{
    $VPNInfo = GetVPNConnectionInfos | Format-Table -AutoSize

    If($VPNInfo -eq $null)
    {
        Write-Warning "Not found VPN conncection in your environment."
    }
    Else
    {
        $VPNInfo

        Do
        {
            $IDs = Read-Host -Prompt "Which VPN connection do you want to remove? Please input their IDs and seperate IDs by comma"
        }
        While($IDs -eq "")

        [Int[]]$IDs = $IDs -split ","
        $TotalID = (GetVPNConnectionInfos).id.count

        Foreach($ID in $IDs)
        {
            If($ID -ge 1 -and $ID -le $TotalID)
            {
                Try
                {
                    $RemoveVPNConnections = GetVPNConnectionInfos | Where ID -EQ $ID
                    If($RemoveVPNConnections.AllUserConnection)
                    {
                        Remove-VpnConnection -Name $RemoveVPNConnections.Name -AllUserConnection -Confirm:$false -Force -Verbose
                    }
                    Else
                    {
                        Remove-VpnConnection -Name $RemoveVPNConnections.Name -Confirm:$false -Force -Verbose
                    }
                }
                Catch
                {
                    Write-Error "Failed to delete VPN connection!'"
                }
            }
            Else
            {
                Write-Error "The input is not corret."
            }
        }
    }
}

Remove-OSCVPNConnection