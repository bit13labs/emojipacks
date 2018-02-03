# https://slackmojis.com/

$url = "https://slackmojis.com/";
"Getting content..." | Write-Host;
$content = Invoke-WebRequest -Uri $url;
"This may take a while..." | Write-Host;
$data = ($content.ParsedHtml.getElementsByTagName("li") | Where { $_.className -match "emoji" });
"Parsing content..."
$output = "title: slackmojis.com`nemoji:`n";

$data | foreach {
  $trigger = $_.title;
  $items = $_.children | where { $_.tagName -eq "a" -and $_.className -eq "downloader" };
  $imgUrl = $items.href;
  "name: '$trigger' src: '$imgUrl'" | Write-Host;
  $output += "  - name: '$trigger'`n    src: '$imgUrl'`n";
};

$output | Out-File -FilePath "./slackemoji.yaml";
