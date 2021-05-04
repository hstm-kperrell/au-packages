$temp = Join-Path -Path $env:TEMP -ChildPath ([GUID]::NewGuid()).Guid
          $null = New-Item -Path $temp -ItemType Directory
          Write-Output "Created temporary directory '$temp'."
          $intRepo = choco list --source=ChocolateyInternal | Select-Object -Skip 1 | Select-Object -SkipLast 1
            foreach ($app in $intRepo) {
                $appSplit = $app.split(" ")
                $name =  $appSplit[0]
                $appVersion =  $appSplit[1]
                $chocoRepo = choco info $name --source='chocolatey' | Select-Object -Skip 1 | Select-Object -First 1
                $chocoSplit = ($chocoRepo.ToString()).Split(" ")
                $chocoVersion =  $chocoSplit[1]
                    if ($chocoVersion -ne "packages"){
                        if ($appVersion -eq $chocoversion) {
                        Write-Verbose "$name is up-to-date on version $chocoVersion"
                        }
                    else {
                        Write-Host "$name is out-of-date on version $appVersion new version is $chocoVersion updating repo now."
$temp = Join-Path -Path $env:TEMP -ChildPath ([GUID]::NewGuid()).Guid
          $null = New-Item -Path $temp -ItemType Directory
          Write-Output "Created temporary directory '$temp'."
          ($env:P_PKG_LIST).split(';') | ForEach-Object {
              choco download $_ --no-progress --internalize --force --internalize-all-urls --append-use-original-location --output-directory=$temp --source='https://chocolatey.org/api/v2/'
              if ($LASTEXITCODE -eq 0) {
				        (Get-Item -Path (Join-Path -Path $temp -ChildPath "*.nupkg")).fullname | ForEach-Object {
      					  choco push $_ --source "$($env:P_DST_URL)" --api-key "$($env:P_API_KEY)" --force
					        if ($LASTEXITCODE -eq 0) {
						        Write-Verbose "Package '$_' pushed to '$($env:P_DST_URL)'.";
					        }
					        else {
						        Write-Verbose "Package '$_' could not be pushed to '$($env:P_DST_URL)'.`nThis could be because it already exists in the repository at a higher version and can be mostly ignored. Check error logs."
					        }
				        }
              }
              else {
                  Write-Output "Failed to download package '$_'"
              }

			      # Clean up, ready for next execution
			      Remove-Item -Path (Join-Path -Path $temp -ChildPath "*.nupkg") -Force
          }
          Remove-Item -Path $temp -Force -Recurse