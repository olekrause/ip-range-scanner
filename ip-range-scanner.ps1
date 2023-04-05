<#
.SYNOPSIS
	Scan an entire class c network.
.DESCRIPTION
	This script is able to ping an entire class c network.
	When done, it will output the IP-addresses and hostnames that were found on the network to the console.
#>

# IP-address from the network you are trying to scan. Doesn't need to be XXX.XXX.XXX.0
$ip = "10.99.10.0"







Get-Job | Remove-Job

$ip -match '\d+.\d+.\d+'
$Matches[0]
for ($i = 0; $i -lt 255; $i++) {
	$range = $Matches[0], $i -join "."
	Test-Connection -ComputerName $range -Count 1 -ErrorAction Stop -AsJob
}

Get-Job | Wait-Job

foreach ($job in Get-Job) {
	$job_result = Receive-Job $Job -Keep
	if ($job_result.responsetime -ge 0) {
		if (Resolve-DnsName $job_result.Address -ErrorAction Ignore) {
			Write-Host $job_result.Address	((Resolve-DnsName $job_result.Address -ErrorAction Ignore).NameHost).TrimEnd(".stadt.wolfsburg.de")
		}
		else {
			Write-Host $job_result.Address
		}
	} 
}