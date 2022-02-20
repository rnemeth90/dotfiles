new-alias -name k -value kubectl

function kdn () {
  param (
    [parameter(Mandatory = $true)]
    [string]$node
  )
  kubectl describe node $node
}

function kdp () {
  param (
    [parameter(Mandatory = $true)]
    [string]$pod
  )
  kubectl describe pod $pod
}

function kns () {
  kubectl get ns
}

function kgn () {
  kubectl get nodes -o wide
}

function kgp () {
  param (
    [Parameter(Mandatory = $false)]
    [string]$namespace
  )
  if ( $namespace ) {
    kubectl get pods -n $namespace -o wide
    break
  }
  kubectl get pods -o wide
}

function kcontext () {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Context
  )
  kubectl config use-context $Context
}

function kn () {
  param (
    [Parameter(Mandatory = $true)]
    [string]$namespace
  )
  kubectl config set-context $(kubectl config current-context) --namespace=$namespace
}