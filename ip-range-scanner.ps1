<#
.SYNOPSIS
	Scans a Class C network subnet for active hosts.
.DESCRIPTION
	This script pings each IP address within a specified Class C network subnet.
	It then outputs the IP addresses and hostnames (if available) of active hosts to the console.
#>

# Set the initial IP address
$ip = "10.108.60.0"

# Remove any existing jobs
Get-Job | Remove-Job

# Extract the subnet from the IP address using regex
$ip -match '\d+.\d+.\d+'
$Matches[0]

# Loop through 0 to 254 (255 iterations)
for ($i = 0; $i -lt 255; $i++) {
	# Create the current IP address by combining the subnet and the current iteration
	$range = $Matches[0], $i -join "."
	
	# Ping the IP address once and create a job for it, suppressing any errors
	Test-Connection -ComputerName $range -Count 1 -ErrorAction Stop -AsJob
}

# Wait for all jobs to complete
Get-Job | Wait-Job

# Clear the console screen
Clear-Host

# Loop through the completed jobs
foreach ($job in Get-Job) {
	# Get the job result
	$job_result = Receive-Job $Job

	
	# If the IP address is online (response time is greater or equal to 0)
	if ($job_result.responsetime -ge 0) {
		# Try to resolve the DNS name of the IP address, suppressing any errors
		if (Resolve-DnsName $job_result.Address -ErrorAction Ignore) {
			# Display the IP address and the trimmed DNS name without the domain suffix
			Write-Host $job_result.Address "	" ((Resolve-DnsName $job_result.Address -ErrorAction Ignore).NameHost).TrimEnd(".stadt.wolfsburg.de")
		}
		else {
			# Display just the IP address if no DNS name is found
			Write-Host $job_result.Address
		}
	} 
}