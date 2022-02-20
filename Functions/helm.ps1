function helmadd() {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$repoName,
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url
    )
    helm repo add $repoName $url
}
function helmrm() {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$repoName
    )
    helm repo remove $repoName
}
function helmls() {
    helm repo list -o yaml
}
function helmsearch() {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$repoName
    )
    helm search repo $repoName
}
function helmupdate() {
    helm repo update
}