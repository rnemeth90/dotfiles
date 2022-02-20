function git-yolo(){
	git commit -am $(curl -s http://whatthecommit.com/index.txt)
}
Set-Alias g 'git'
function gb { git branch }
function gad {git add .}
function gd { git diff }
function gpull { git pull }
function gstatus { git status }

function gclone(){
  param (
      [Parameter(Mandatory=$true)]
      [string]$url
  )
  git clone $url
}

function gcheckout(){
  param (
      [Parameter(Mandatory=$true)]
      [string]$branchName
  )
  git checkout -b $branchName
}

function gpush { git push }
function gbranch { git branch }
function gs { git status -sb }
function gf { git fetch --prune }
function grevertlast { git reset --soft HEAD~1 }
function glog {
  # x09 is a tab
  git log --oneline --pretty=format:"%C(yellow)%h%C(reset)%x09%C(magenta)%an%C(reset)%x09%C(yellow)%ad%C(reset)%x09%s"
}
function gpo {
  $CurrentBranch = Get-Git-CurrentBranch
  git push --set-upstream origin $CurrentBranch
}
function gp {
  $CurrentBranch = Get-Git-CurrentBranch
  git pull origin $CurrentBranch
}
function myproject {
  git config user.name "Ryan Nemeth"
  git config user.email "ryan@geekyryan.com"
}
function Get-Git-CurrentBranch {
  git symbolic-ref --quiet HEAD *> $null
  if ($LASTEXITCODE -eq 0) {
    return git rev-parse --abbrev-ref HEAD
  }
  else {
    return
  }
}

function gpa{
  Get-ChildItem -Directory | `
  Foreach-Object {
    Write-Host "`n Getting latest for $_ :" -ForegroundColor Green | `
    git -C $_.FullName pull --all --recurse-submodules --verbose
  }
}