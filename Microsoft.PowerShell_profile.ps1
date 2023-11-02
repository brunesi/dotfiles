function prompt {
    Write-Host "PS $(Get-Location)`n" -NoNewline
    Write-Host ">" -NoNewline -ForegroundColor DarkGreen
    return " "
}
