Import-Module Microsoft.Graph.Users
Connect-Graph -Scopes User.ReadWrite.All
Get-MgUser