$Secret = "C:\Users\xclinquart\OneDrive - axxes.com\Documents\Talks\Inpersonmeetup30-01-2024\Secret.txt"
#Tenant BEPUG
$ClientId    = 'a53d95e1-f0d0-4b54-a1fd-cffdc468997e'
$TenantId    = '0f2530d7-a0b6-4d1c-8812-28c395f50309'
#region authentication
# Interactive login with MSAL
$AuthParams = @{
    ClientId    = $ClientId
    TenantId    = $TenantId
    Interactive = $true
}
$Auth = Get-MsalToken @AuthParams
$AccessToken = $Auth.AccessToken

# Client secret login with MSAL
$AuthParams = @{
    ClientId    = $ClientId
    TenantId    = $TenantId
    ClientSecret = (Get-Content $Secret | ConvertTo-SecureString -AsPlainText -Force )
}
$Auth = Get-MsalToken @AuthParams
$AccessToken = $Auth.AccessToken


# Client secret login with native PowerShell commands
$AuthParams = @{
    Method      = "POST"
    URI = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    Body = @{
        client_id     = $ClientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = Get-Content $Secret
        grant_type    = "client_credentials"
    }
    ContentType = "application/x-www-form-urlencoded"
    UseBasicParsing = $true
}
$Auth = Invoke-RestMethod @AuthParams

$AccessToken = $Auth.access_token
#endregion

#region graph API Call


#graph
# Retrieve info about the logged in user
$GraphGetParams = @{
    Headers     = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $($AccessToken)"
    }
    Method      = "GET"
    ErrorAction = "SilentlyContinue"
    Uri = "https://graph.microsoft.com/v1.0/me"
}

Invoke-RestMethod @GraphGetParams 


# Retrieve all users from the tenant as an application without user login interaction
# Requires Application permissions Directory.Read.All , User.Read.All
$GraphGetParams = @{
    Headers     = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $($AccessToken)"
    }
    Method      = "GET"
    ErrorAction = "SilentlyContinue"
    Uri = "https://graph.microsoft.com/v1.0/users"
}

$Output = Invoke-RestMethod @GraphGetParams 

$Attachment = "C:\Users\xclinquart\OneDrive - axxes.com\Documents\Talks\Inpersonmeetup30-01-2024\Users.csv"
$Output.value | ConvertTo-Csv | Out-File -FilePath $Attachment
#Get File Name and Base64 string
$FileName=(Get-Item -Path $Attachment).name
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Attachment))

# Send email from graph as any mailbox user with attachment 
# Requires Application permissions Mail.Send

$GraphGetParams = @{
    Headers     = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $($AccessToken)"
    }
    Method      = "POST"
    ErrorAction = "SilentlyContinue"
    Uri = "https://graph.microsoft.com/v1.0/users/bepug@bepug.be/sendMail"
    Body =   @{
        message = @{
            subject = "Welcome to BEPUG"
            body = @{
                contentType = "Text"
                content = "Welcome to BEPUG"
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = "xavier@bepug.be"
                    }
                }
            )
            attachments = @(
                @{
                    "@odata.type" = "#microsoft.graph.fileAttachment"
                    name = "$FileName"
                    contentType = "text/plain"
                    contentBytes = "$base64string"
                }
            )
        }
    } | ConvertTo-Json -Depth 5 
}


Invoke-RestMethod @GraphGetParams 
#endregion