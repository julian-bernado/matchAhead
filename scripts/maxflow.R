library("rlemon")
library("optmatch")

generate_network <- function(M, max.controls){
  nt <- nrow(M)
  nc <- ncol(M)
  
  from_nodes = c()
  to_nodes = c()
  capacities = c()
  
  for (i in 1:nt) {
    for(j in 1:nc){
      if(length(M[i,j]) == 1){
        from_nodes = c(from_nodes, 2 + i)
        to_nodes = c(to_nodes, 2 + nt + j)
        capacities = c(capacities, 1)
      }
    }
  }
  
  for(i in 1:nt){
    from_nodes = c(from_nodes, 1)
    to_nodes = c(to_nodes, 2+i)
    capacities = c(capacities, max.controls)
  }
  
  for(j in 1:nc){
    from_nodes = c(from_nodes, 2+nt+j)
    to_nodes = c(to_nodes, 2)
    capacities = c(capacities, 1)
  }
  
  network = list(from_node = from_nodes,
                 to_node = to_nodes,
                 capacity = capacities)
  return(network)
}

max_controls <- function(M, max.controls){
  nwk <- generate_network(M, max.controls)
  resulting_maxflow <- MaxFlow(arcSources = nwk[["from_node"]],
                               arcTargets = nwk[["to_node"]],
                               arcCapacities = nwk[["capacity"]],
                               sourceNode = 1,
                               destNode = 2,
                               numNodes = ncol(M) + nrow(M) + 2)
  return(resulting_maxflow[["cost"]])
}