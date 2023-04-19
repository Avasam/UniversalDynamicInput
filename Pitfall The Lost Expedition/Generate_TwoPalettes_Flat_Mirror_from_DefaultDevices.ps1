# Adapted from SplitBATexture in https://github.com/Helco/Pitfall/blob/master/TexConvert/TexConvert.cs#L363
# Not the most efficient, but it works, and shouldn't need to be run often.
# Read https://stackoverflow.com/a/64969552 for potential improvement.
Function Save-SplitRGAndBAImage {
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [System.IO.FileInfo] $Source,
    [Parameter(Mandatory = $true)]
    [string] $DestinationFolder
  )

  Process {
    Write-Host $Source
    $image = New-Object System.Drawing.Bitmap $Source.FullName
    $imageRG = New-Object System.Drawing.Bitmap($image.Width, $image.Height)
    $imageBA = New-Object System.Drawing.Bitmap($image.Width, $image.Height)

    foreach ($x in 0..($image.Width - 1)) {
      foreach ($y in 0..($image.Height - 1)) {
        $pixelColor = $image.GetPixel($x, $y)
        $imageRG.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($pixelColor.G, $pixelColor.R, $pixelColor.R, $pixelColor.R))
        $imageBA.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($pixelColor.A, $pixelColor.B, $pixelColor.B, $pixelColor.B))
      }
    }

    $imageRG.Save("$destinationFolder/$($Source.BaseName)_RG.png")
    $imageBA.Save("$destinationFolder/$($Source.BaseName)_BA.png")

    $image.Dispose()
    $imageRG.Dispose()
    $imageBA.Dispose()
  }
}


Get-ChildItem "$PSScriptRoot/../#DefaultDevices/_Mirror" |
  ForEach-Object {
    $destinationFolder = "$PSScriptRoot/TwoPalettes_Flat_Mirror/$($_.Name)"
    # Create the folders
    if (!(Test-Path -Path $destinationFolder)) { New-Item $destinationFolder -Type Directory }
    # Split and copy the images
    if (Test-Path -Path "$($_.FullName)/Device") {
      # Not all device packs have "Device" images
      Get-ChildItem "$($_.FullName)/Device" | Save-SplitRGAndBAImage -DestinationFolder $destinationFolder
    }
    Get-ChildItem "$($_.FullName)/Flat" | Save-SplitRGAndBAImage -DestinationFolder $destinationFolder
  }

Set-Content `
  "$PSScriptRoot/TwoPalettes_Flat_Mirror/README.md" `
  @"
This folder was generated using the ``Generate_TwoPalettes_Flat_Mirror_from_DefaultDevices.ps1`` script.  
It's a copy of [/#DefaultDevices/_Mirror/*/(Flat|Device)](/%23DefaultDevices/_Mirror) with the textures split in two palettes.  
The script can be run anytime a ``*_Flat_Mirror`` pack is updated to keep ``TwoPalettes_Flat_Mirror`` up to date.  
"@
