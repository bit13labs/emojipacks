# https://slackmojis.com/

$url = "https://slackmojis.com/";
$content = Invoke-WebRequest -Uri $url;
$data = ($content.ParsedHtml.getElementsByTagName("li") | Where { $_.className -match "emoji" });

$output = "title: slackmojis.com`nemoji:`n";

$data | foreach {
  $trigger = $_.title;
  $items = $_.children | where { $_.tagName -eq "a" -and $_.className -eq "downloader" };
  $imgUrl = $items.href;
  $output += "  - name: '$trigger'`n    src: '$imgUrl'`n";
};

$output | Out-File -FilePath "./slackemoji.yaml";