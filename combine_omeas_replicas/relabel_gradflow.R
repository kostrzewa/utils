#!/usr/bin/env Rscript
require(pbmcapply)
args <- commandArgs(trailingOnly = TRUE)
if( length(args) < 1 ){
  stop("usage: Rscript relabel_gradflow.R <filelist.txt>")
}

files <- read.table(args[1], header=TRUE, stringsAsFactors=FALSE)

silent <- pbmcapply::pbmclapply(
  X = 1:nrow(files),
  FUN = function(rw){
    dat <- read.table(file=files$src_file[rw], stringsAsFactors=FALSE, header=TRUE)
    dat$traj <- files$target_idx[rw]
    write.table(dat, file=sprintf("gradflow.%06d", as.numeric(files$target_idx[rw]) ),
                row.names=FALSE, col.names=TRUE, quote=FALSE)
  })

