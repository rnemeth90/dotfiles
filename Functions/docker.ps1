function prune() {
    docker system prune --force
}

function pruneAll() {
    docker system prune --all --force
}


function images(){
    docker images
}

function dst { # Docker Status
    docker container ls -a;
    docker images -a;
    docker ps;
  }
  function dcud { docker-compose up -d }
  function dcd { docker-compose down }
  # Make
  Set-Alias m 'make'
