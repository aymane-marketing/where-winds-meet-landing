param($port = 8080, $dir = ".")
Set-Location $dir
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port/"
try {
    while ($true) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $path = $request.Url.LocalPath.TrimStart('/')
            if ($path -eq "") { $path = "index.html" }
            $localPath = Join-Path (Get-Location) $path
            
            if (Test-Path $localPath -PathType Leaf) {
                $content = [System.IO.File]::ReadAllBytes($localPath)
                $response.ContentLength64 = $content.Length
                
                $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
                switch ($ext) {
                    ".html" { $response.ContentType = "text/html" }
                    ".css"  { $response.ContentType = "text/css" }
                    ".js"   { $response.ContentType = "application/javascript" }
                    ".png"  { $response.ContentType = "image/png" }
                    ".jpg"  { $response.ContentType = "image/jpeg" }
                    ".mp4"  { $response.ContentType = "video/mp4" }
                    default { $response.ContentType = "application/octet-stream" }
                }
                
                $output = $response.OutputStream
                $output.Write($content, 0, $content.Length)
                $output.Close()
            } else {
                $response.StatusCode = 404
                $output = $response.OutputStream
                $output.Close()
            }
        } catch {
            Write-Host "Error serving request: $_"
        }
    }
} finally {
    $listener.Stop()
}
