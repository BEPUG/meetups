Enter-WslDistribution -DistributionName ubuntu

Invoke-WslCommand -DistributionName ubuntu -Scriptblock {$PSVersionTAble}

Invoke-WslCommand -DistributionName ubuntu -Scriptblock {hostname}
