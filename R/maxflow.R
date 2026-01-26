# R/maxflow.R
# Maximum flow algorithm for optimal matching using rlemon

#' Generate network structure for max-flow problem
#'
#' Creates a bipartite network from treatment to control units
#' with source and sink nodes for max-flow computation.
#'
#' @param M Distance/validity matrix (treatment x control), NA = invalid
#' @param max.controls Maximum number of controls per treatment unit
#' @return List with from_node, to_node, capacity vectors
generate_network <- function(M, max.controls) {
  nt <- nrow(M)
  nc <- ncol(M)

  # Find all valid matches (non-NA entries)
  match_indices <- which(!is.na(M), arr.ind = TRUE)

  # Node numbering: 1 = source, 2 = sink, 3:(2+nt) = treatments, (3+nt):(2+nt+nc) = controls

  # Edges from treatments to controls
  from_nodes <- 2 + match_indices[, 1]
  to_nodes <- 2 + nt + match_indices[, 2]
  capacities <- rep(1, nrow(match_indices))

  # Edges from source to treatments
  from_nodes <- c(from_nodes, rep(1, nt))
  to_nodes <- c(to_nodes, 2 + 1:nt)
  capacities <- c(capacities, rep(max.controls, nt))

  # Edges from controls to sink
  from_nodes <- c(from_nodes, 2 + nt + 1:nc)
  to_nodes <- c(to_nodes, rep(2, nc))
  capacities <- c(capacities, rep(1, nc))

  network <- list(
    from_node = from_nodes,
    to_node = to_nodes,
    capacity = capacities
  )

  return(network)
}

#' Compute maximum flow through bipartite matching network
#'
#' @param M Distance/validity matrix (treatment x control), NA = invalid
#' @param max.controls Maximum number of controls per treatment unit
#' @return List with cost (flow value) and flows (edge flow values)
max_controls <- function(M, max.controls) {
  nwk <- generate_network(M, max.controls)

  resulting_maxflow <- rlemon::MaxFlow(
    arcSources = nwk[["from_node"]],
    arcTargets = nwk[["to_node"]],
    arcCapacities = nwk[["capacity"]],
    sourceNode = 1,
    destNode = 2,
    numNodes = ncol(M) + nrow(M) + 2
  )

  return(resulting_maxflow)
}
