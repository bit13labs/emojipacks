
param (
  [string] $Subdomain,
  [string] $Email,
  [string] $Password,
  [string] $PackPath = "./packs",
  [string[]] $PackIncludes = @("*.yaml", "*.yml")
)

$packs = Get-ChildItem -Path "$PackPath/*" -Include $PackIncludes;

$packs | foreach {
  $pack = $_;
  "Importing $pack" | Write-Host;
  & node ./bin/emojipacks -s $Subdomain -e $Email -p $Password -y $pack;
}
