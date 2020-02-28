
#### This is function to calculate the mValue of a distribution using an R script
#### two parameters are given: the distribution values to measure and the sistem 
#### to calculate the number of bins: SQRT or FD

mValue = function(To.Measure, bin_system){

  if (bin_system == "SQRT"){r <- ceiling(sqrt(length(To.Measure)))}
  if (bin_system == "FD"){
    bw <- 2 *(IQR(To.Measure) / length(To.Measure)^(1/3))
    r <- ((max(To.Measure) - min(To.Measure))/bw)
    r = ceiling(r)
  }
  
  mValues.Store = data.frame(matrix(ncol = 1, nrow = 0))
  To.Measure = as.data.frame(To.Measure)
  colnames(To.Measure) = c("Measured")
  
  Hist.mVal = ggplot(To.Measure, aes(x = Measured)) + 
    geom_histogram(bins = r, color="black", fill="gray70") +
    theme_light() +
    ylab("Case count") + xlab("Measured variable") +
    theme(axis.text = element_text(size = 6.5, color = "black"),
          axis.title = element_text(size = 7.5, color = "black", face = "bold"))         
  Hist.Counts = ggplot_build(Hist.mVal)$data[[1]]$count
  result = sum(abs(diff(Hist.Counts)))
  Modal.Value = result/max(Hist.Counts)
  Modal.Value
  mValues.Store = rbind(mValues.Store, Modal.Value)
  
  Hist.mVal = ggplot(To.Measure, aes(x = Measured)) + 
    geom_histogram(bins = (r-1), color="black", fill="gray70") +
    theme_light() +
    ylab("Case count") + xlab("Measured variable") +
    theme(axis.text = element_text(size = 6.5, color = "black"),
          axis.title = element_text(size = 7.5, color = "black", face = "bold"))         
  Hist.Counts = ggplot_build(Hist.mVal)$data[[1]]$count
  result = sum(abs(diff(Hist.Counts)))
  Modal.Value = result/max(Hist.Counts)
  Modal.Value
  mValues.Store = rbind(mValues.Store, Modal.Value)
  
  Hist.mVal = ggplot(To.Measure, aes(x = Measured)) + 
    geom_histogram(bins = (r-2), color="black", fill="gray70") +
    theme_light() +
    ylab("Case count") + xlab("Measured variable") +
    theme(axis.text = element_text(size = 6.5, color = "black"),
          axis.title = element_text(size = 7.5, color = "black", face = "bold"))         
  Hist.Counts = ggplot_build(Hist.mVal)$data[[1]]$count
  result = sum(abs(diff(Hist.Counts)))
  Modal.Value = result/max(Hist.Counts)
  Modal.Value
  mValues.Store = rbind(mValues.Store, Modal.Value)
  
  Hist.mVal = ggplot(To.Measure, aes(x = Measured)) + 
    geom_histogram(bins = (r-3), color="black", fill="gray70") +
    theme_light() +
    ylab("Case count") + xlab("Measured variable") +
    theme(axis.text = element_text(size = 6.5, color = "black"),
          axis.title = element_text(size = 7.5, color = "black", face = "bold"))         
  Hist.Counts = ggplot_build(Hist.mVal)$data[[1]]$count
  result = sum(abs(diff(Hist.Counts)))
  Modal.Value = result/max(Hist.Counts)
  Modal.Value
  mValues.Store = rbind(mValues.Store, Modal.Value)
  
  Hist.mVal = ggplot(To.Measure, aes(x = Measured)) + 
    geom_histogram(bins = (r+1), color="black", fill="gray70") +
    theme_light() +
    ylab("Case count") + xlab("Measured variable") +
    theme(axis.text = element_text(size = 6.5, color = "black"),
          axis.title = element_text(size = 7.5, color = "black", face = "bold"))         
  Hist.Counts = ggplot_build(Hist.mVal)$data[[1]]$count
  result = sum(abs(diff(Hist.Counts)))
  Modal.Value = result/max(Hist.Counts)
  Modal.Value
  mValues.Store = rbind(mValues.Store, Modal.Value)
  
  Hist.mVal = ggplot(To.Measure, aes(x = Measured)) + 
    geom_histogram(bins = (r+2), color="black", fill="gray70") +
    theme_light() +
    ylab("Case count") + xlab("Measured variable") +
    theme(axis.text = element_text(size = 6.5, color = "black"),
          axis.title = element_text(size = 7.5, color = "black", face = "bold"))         
  Hist.Counts = ggplot_build(Hist.mVal)$data[[1]]$count
  result = sum(abs(diff(Hist.Counts)))
  Modal.Value = result/max(Hist.Counts)
  Modal.Value
  mValues.Store = rbind(mValues.Store, Modal.Value)
  
  Hist.mVal = ggplot(To.Measure, aes(x = Measured)) + 
    geom_histogram(bins = (r+3), color="black", fill="gray70") +
    theme_light() +
    ylab("Case count") + xlab("Measured variable") +
    theme(axis.text = element_text(size = 6.5, color = "black"),
          axis.title = element_text(size = 7.5, color = "black", face = "bold"))         
  Hist.Counts = ggplot_build(Hist.mVal)$data[[1]]$count
  result = sum(abs(diff(Hist.Counts)))
  Modal.Value = result/max(Hist.Counts)
  Modal.Value
  mValues.Store = rbind(mValues.Store, Modal.Value)
  
  return(max(mValues.Store))
  
}
