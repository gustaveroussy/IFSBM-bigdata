#' Mutation order for SBS in 96-class
#'
#' @return an character vector of ordered mutation trinucleotide context in format "W[X>Y]Z".
#'
#' @keywords internal
mutations_order_sbs_96 <- function(){
  nucl <- c("A", "C", "G", "T")
  chg <- c("C>A", "C>G", "C>T", "T>A", "T>C", "T>G")

  right_nucl <- rep(nucl, length.out=96)
  left_nucl <- rep(nucl, each=4, length.out=96)
  middle_chg <- rep(chg, each=16, length.out=96) 

  paste0(left_nucl, "[", middle_chg, "]", right_nucl)
}

#' Mutation order for SBS in 192-class
#'
#' @return an character vector of ordered mutation trinucleotide context with strand in format "W[X>Y]Z-U/T".
#'
#' @keywords internal
mutations_order_sbs_192 <- function(){
  order_sbs_96 <- mutations_order_sbs_96()

  c(paste0("T:", order_sbs_96), paste0("U:", order_sbs_96))
}

#' Mutation order for DBS in 78-class
#'
#' @return an character vector of ordered doublet context in format "W[X>Y]Z".
#'
#' @keywords internal
mutations_order_dbs_78 <- function(){
  c("AC>CA" ,"AC>CG" ,"AC>CT" ,"AC>GA" ,"AC>GG" ,"AC>GT" ,"AC>TA" ,"AC>TG" ,"AC>TT" ,"AT>CA" ,"AT>CC" ,"AT>CG",
  "AT>GA" ,"AT>GC" ,"AT>TA" ,"CC>AA" ,"CC>AG" ,"CC>AT" ,"CC>GA" ,"CC>GG" ,"CC>GT" ,"CC>TA" ,"CC>TG" ,"CC>TT",
  "CG>AT" ,"CG>GC" ,"CG>GT" ,"CG>TA" ,"CG>TC" ,"CG>TT" ,"CT>AA" ,"CT>AC" ,"CT>AG" ,"CT>GA" ,"CT>GC" ,"CT>GG",
  "CT>TA" ,"CT>TC" ,"CT>TG" ,"GC>AA" ,"GC>AG" ,"GC>AT" ,"GC>CA" ,"GC>CG" ,"GC>TA" ,"TA>AT" ,"TA>CG" ,"TA>CT",
  "TA>GC" ,"TA>GG" ,"TA>GT" ,"TC>AA" ,"TC>AG" ,"TC>AT" ,"TC>CA" ,"TC>CG" ,"TC>CT" ,"TC>GA" ,"TC>GG" ,"TC>GT",
  "TG>AA" ,"TG>AC" ,"TG>AT" ,"TG>CA" ,"TG>CC" ,"TG>CT" ,"TG>GA" ,"TG>GC" ,"TG>GT" ,"TT>AA" ,"TT>AC" ,"TT>AG",
  "TT>CA" ,"TT>CC" ,"TT>CG" ,"TT>GA" ,"TT>GC" ,"TT>GG")
}


#' Mutation order for each context.
#'
#' @param mutation_mode Define how mutations are categorized. You may choose
#' \itemize{
#'   \item{SBS_96}{For single-base substitutions, disregarding the strand.}
#'   \item{SBS_192}{For single-base substitutions, discriminating between strands.}
#'   \item{DBS_78}{For doublet-base substitutions, disregarding the strand.}
#'   \item{ID}{For insertions-deletions.}
#' }
#' @return an character vector of ordered mutation contexts.
#' @export
mutations_order <- function(mutation_mode=c("SBS_96", "SBS_192", "DBS_78", "ID")){
  mutation_mode <- match.arg(mutation_mode)
  if (mutation_mode=="SBS_96"){
    return(mutations_order_sbs_96())
  } else if (mutation_mode=="SBS_192"){
    return(mutations_order_sbs_192())
  } else if (mutation_mode=="DBS_78"){
    return(mutations_order_dbs_78())
  } else {
    return(NULL)
  }
}
