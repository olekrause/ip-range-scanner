# Network Scanner
## Overview

This PowerShell script scans a Class C network subnet for active hosts. It outputs the IP addresses and hostnames (if available) of active hosts to the console.
## Features

Scans a specified Class C network subnet.
Pings each IP address within the subnet.
Displays active IP addresses and hostnames (if available).

## Prerequisites

PowerShell version 3.0 or later.

## Usage

Open PowerShell.
Navigate to the directory containing the script.
Set the initial IP address in the script to the desired value. Forexample:

```PowerShell
$ip = "10.108.60.0"
```

Run the script:

```PowerShell
".\path\to\the\ip-range-scanner.ps1"
```

The script will then ping each IP address in the subnet once and display the IP addresses and hostnames (if available) of active hosts.
## Output

The output will be displayed in the console. Each active host will be listed with its IP address, and if a hostname is available, it will be displayed next to the IP address, separated by a tab. If no hostname is found, only the IP address will be displayed.