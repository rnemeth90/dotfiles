function azsubs {
    Get-AzSubscription
}

function azmylab {
    set-azcontext -subscriptionname "Visual Studio Professional Subscription"
}

function azprod {
    set-azcontext -subscriptionname "production"
}

function aznonprod {
    set-azcontext -subscriptionname "non-production"
}

function aztraining {
    set-azcontext -subscriptionname "internal training"
}