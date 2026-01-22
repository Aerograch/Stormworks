$RepoDir = "C:\path\to\your\repo"
$Branch = "main"

param (
    [string]$CommitMessage = "auto update"
)

Set-Location $RepoDir

$status = git status --porcelain
if ($status.Length -eq 0) {
    Write-Host "Нет изменений для коммита"
    exit
}

git add .
git commit -m $CommitMessage
git push origin $Branch

Write-Host "Репозиторий обновлён"
