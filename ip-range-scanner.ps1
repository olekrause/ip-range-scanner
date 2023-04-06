function Get-ActiveIPAddresses {
	<#
	.SYNOPSIS
		This function scans a subnet for active IP addresses and resolves their hostnames, if available.
 
	.DESCRIPTION
		This function first removes any existing PowerShell jobs, then iterates through a range of IP addresses within a subnet
		and tests the connection to each address. After all connections are tested, the function outputs a table with
		the active IP addresses and their corresponding hostnames, if resolvable.
 
	.PARAMETER ip
		The starting IP address for the subnet to be scanned.

	.PARAMETER startRange
		The starting value of the IP range counter. Default value is 0.
		This value is used in the loop to iterate through the IP addresses within the subnet.

	.PARAMETER endRange
		The ending value of the IP range counter, exclusive. Default value is 255.
		This value is used in the loop to determine the stopping point for iterating through the IP addresses within the subnet.

	.EXAMPLE
		To use this function, call it with the desired starting IP address and optional startRange and endRange values:
		Get-ActiveIPAddresses -ip "10.108.60.0" -startRange 5 -endRange 120

	.INPUTS
		The input for this function is the ip parameter, which should be set to the starting IP address of the desired subnet.
		Optionally, you can provide the startRange and endRange parameters to customize the IP range to be scanned.

	.OUTPUTS
		The function outputs a table with two columns: "IP-address" and "Hostname". Active IP addresses are listed in the "IP-address" column,
		and their corresponding hostnames, if resolvable, are listed in the "Hostname" column.

	.NOTES
		This function assumes that the subnet has a range of 255 IP addresses, starting from the 1st address and up to the 255th address.
		Adjust the loop range in the script if you need to scan a different range of IP addresses.
	
	.LINK
		https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help
		https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions
		https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection
		https://docs.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname
		https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-job
		https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/wait-job

	#>
 
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$ip,
		[Parameter(Position = 1)]
		[int]$startRange = 0,
		[Parameter(Position = 2)]
		[int]$endRange = 255
	)
	
	
	# Get all PowerShell jobs and store them in a variable
	$jobs = Get-Job
	
	# If there are any existing jobs, remove them
	if ($jobs) { Remove-Job -Job $jobs }
	
	# Use regex to extract the base IP from the given IP address
	$ip -match '(\d+\.\d+\.\d+)\.'
	$baseIP = $Matches[1]
	
	# Loop through IP addresses in the subnet, starting from the 5th address and up to 254
	for ($i = $startRange; $i -le $endRange; $i++) {
		# Create a new IP address in the range using the base IP and the loop counter
		$ipRange = "$baseIP.$i"
		# Test the connection to the IP address and run it as a background job
		Test-Connection -ComputerName $ipRange -Count 1 -ErrorAction Stop -AsJob
	}
	
	# Wait for all the background jobs to complete
	Get-Job | Wait-Job
	# Clear the console screen
	Clear-Host
	
	# Output the header for the results table
	Write-Host "IP-address" "`t" "Hostname`n"
	
	# Loop through each job and process the results
	foreach ($job in Get-Job) {
		# Receive the job results
		$jobResult = Receive-Job $job
		# Check if the response time is greater than or equal to 0, indicating a successful connection
		if ($jobResult.ResponseTime -ge 0) {
			# Try to resolve the DNS name for the IP address, ignoring any errors
			$dnsResult = Resolve-DnsName $jobResult.Address -ErrorAction Ignore
			# If a DNS result is returned, output the IP address and corresponding hostname
			if ($dnsResult) {
				Write-Host $jobResult.Address "`t" ($dnsResult.NameHost).TrimEnd(".stadt.wolfsburg.de")
			}
			# If no DNS result is returned, output just the IP address
			else {
				Write-Host $jobResult.Address
			}
		}
	}
}