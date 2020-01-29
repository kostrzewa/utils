require(dplyr)

prefix <- "cB211"
suffix <- "25.24"

replicas <- sprintf("%s%s.%s", prefix, c("b","a"), suffix)

odat <- NULL
for( rep_idx in 1:length(replicas) ){
  dat <- read.table(file = sprintf("../%s/output.data", replicas[rep_idx]),
                    stringsAsFactors = FALSE)
  nb_cols <- ncol(dat)
  var_cols <- nb_cols-7
  colnames(dat) <- c("traj", "P", "dh", "expdh", sprintf("v%d", 1:var_cols), "acc", "trajtime", "rect")
  
  dat <- dplyr::distinct(dat, traj, .keep_all = TRUE)
  if(rep_idx == 1){
    dat <- dplyr::arrange(dat, rev(traj))
  }
  odat <- rbind(odat, dat) 
}

odat <- dplyr::mutate(odat, traj = dplyr::row_number())

write.table(odat, file = "output.data", quote = FALSE, row.names=FALSE, col.names=FALSE)

