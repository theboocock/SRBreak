\name{detectBreakpointFromPairedEnds}
\alias{detectBreakpointFromPairedEnds}
\title{
  Use paired-end reads to refine breakpoints
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
detectBreakpointFromPairedEnds(resultFromRD = NULL, dirBamFile = NULL, windows = 500, chr = NULL, qualityThreshold = 0, epsilonPairedOpen = NULL, thresholdOfIntersection = 0.9, insertSize = 500, readLength = 100)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{resultFromRD}{
%%     ~~Describe \code{resultFromRD} here~~
}
  \item{dirBamFile}{
%%     ~~Describe \code{dirBamFile} here~~
}
  \item{windows}{
%%     ~~Describe \code{windows} here~~
}
  \item{chr}{
%%     ~~Describe \code{chr} here~~
}
  \item{qualityThreshold}{
%%     ~~Describe \code{qualityThreshold} here~~
}
  \item{epsilonPairedOpen}{
%%     ~~Describe \code{epsilonPairedOpen} here~~
}
  \item{thresholdOfIntersection}{
%%     ~~Describe \code{thresholdOfIntersection} here~~
}
  \item{insertSize}{
%%     ~~Describe \code{insertSize} here~~
}
  \item{readLength}{
%%     ~~Describe \code{readLength} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (resultFromRD = NULL, dirBamFile = NULL, windows = 500, 
    chr = NULL, qualityThreshold = 0, epsilonPairedOpen = NULL, 
    thresholdOfIntersection = 0.9, insertSize = 500, readLength = 100) 
{
    if (is.na(dirBamFile)) 
        dirBamFile <- "./"
    if (substr(dirBamFile, length(dirBamFile), 1) != "/") 
        dirBamFile <- paste(dirBamFile, "/", sep = "")
    if (is.null(windows)) 
        stop("Please input windows used in the read-depth based approach")
    if (is.null(chr)) 
        stop("Please input chr")
    if (is.null(epsilonPairedOpen)) 
        epsilonPairedOpen <- 2 * windows
    normalGroup <- resultFromRD[resultFromRD[, dim(resultFromRD)[2]] == 
        "NORMAL", ]
    resultFromRD <- resultFromRD[resultFromRD[, dim(resultFromRD)[2]] != 
        "NORMAL", ]
    tempGroup <- rep(1, dim(resultFromRD)[1])
    nAA <- 2
    if (length(tempGroup) > 1) {
        for (kk in 2:(dim(resultFromRD)[1])) {
            if ((resultFromRD[kk, 2] != resultFromRD[kk - 1, 
                2]) | (resultFromRD[kk, 3] != resultFromRD[kk - 
                1, 3])) {
                tempGroup[kk:(length(tempGroup))] <- nAA
                nAA <- nAA + 1
            }
        }
    }
    names(tempGroup) <- resultFromRD[, 1]
    groupFromRD <- as.numeric(names(table(tempGroup)))
    groupTableFromRD <- cbind(resultFromRD, tempGroup)
    Nnormal <- dim(normalGroup)[1]
    tempDataFrameOut <- NULL
    for (gG in groupFromRD) {
        message(gG)
        subGroupFromRD <- names(tempGroup[tempGroup == gG])
        SubgroupTableFromRD <- groupTableFromRD[groupTableFromRD[, 
            dim(groupTableFromRD)[2]] == gG, ]
        tempPairedEndOut <- getPairedEndPositionForGroup(dirBamFile = dirBamFile, 
            listFile = SubgroupTableFromRD[, 1], chr = chr, windows = windows, 
            medLeft = SubgroupTableFromRD[, 2][1], medRight = SubgroupTableFromRD[, 
                3][1], thresholdOfIntersection = thresholdOfIntersection, 
            typeSV = toupper(as.character(SubgroupTableFromRD[, 
                5])[1]))
        SubgroupTableFromRD$Start <- tempPairedEndOut[1]
        SubgroupTableFromRD$End <- tempPairedEndOut[2]
        tempDataFrameOut <- rbind(tempDataFrameOut, SubgroupTableFromRD)
    }
    if (!is.null(tempDataFrameOut)) {
        mergeTemp <- NULL
        mergeRemove <- tempDataFrameOut
        while (dim(mergeRemove)[1] >= 1) {
            xTemp <- mergeRemove[1, ]
            tempT1 <- mergeRemove[as.character(mergeRemove[, 
                5]) == as.character(xTemp[, 5]), ]
            tempT1 <- tempT1[abs(tempT1[, 2] - xTemp[, 2]) <= 
                (insertSize - 2 * readLength), ]
            tempT1 <- tempT1[abs(tempT1[, 3] - xTemp[, 3]) <= 
                (insertSize - 2 * readLength), ]
            if (tempT1[1, 5] == "DEL") {
                tempT1[, 2] <- round(quantile(tempT1[, 2], 0.9))
                tempT1[, 3] <- round(quantile(tempT1[, 3], 0.1))
            }
            else {
                tempT1[, 2] <- round(quantile(tempT1[, 2], 0.1))
                tempT1[, 3] <- round(quantile(tempT1[, 3], 0.9))
            }
            mergeTemp <- rbind(mergeTemp, tempT1)
            mergeRemove <- mergeRemove[-pmatch(rownames(tempT1), 
                rownames(mergeRemove)), ]
        }
        tempDataFrameOut <- mergeTemp
        tempDataFrameOut <- tempDataFrameOut[, -dim(tempDataFrameOut)[2]]
        colnames(tempDataFrameOut) <- paste("V", 1:dim(tempDataFrameOut)[2], 
            sep = "")
    }
    colnames(normalGroup) <- paste("V", 1:dim(normalGroup)[2], 
        sep = "")
    ppOut <- rbind(tempDataFrameOut, normalGroup)
    rownames(ppOut) <- as.character(ppOut[, 1])
    return(ppOut)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
