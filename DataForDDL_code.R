rm(list=ls())
library(haven)
library(DDL)
DDL <- read_dta("DataForDDL.dta")

# test for EP_EIDQ
A <- as.matrix(DDL[, 3:100])
B <- as.matrix(DDL$EP_EIDQ)
result1=DDL(A,B,1)
result1
summary(result1)

# test for EP_HeXun
DDL1 <-na.omit(DDL)
A <- as.matrix(DDL1[, 3:100])
C <- as.matrix(DDL1$EP_HeXun)
result2=DDL(A,C,1)
result2
summary(result2)
