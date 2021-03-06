\name{getSplitReadBreakpoint}
\alias{getSplitReadBreakpoint}
\title{
Obtain breakpoints using read-depth information
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
getSplitReadBreakpoint(resultFromRD = NULL, dirBamFile = NULL, windows = 500, chr = NULL, qualityThreshold = 0, epsilonOpen = NULL, sdSplitRead = 0.5, usingPairedEnds = TRUE)
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
  \item{epsilonOpen}{
%%     ~~Describe \code{epsilonOpen} here~~
}
  \item{sdSplitRead}{
%%     ~~Describe \code{sdSplitRead} here~~
}
  \item{usingPairedEnds}{
%%     ~~Describe \code{usingPairedEnds} here~~
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
    chr = NULL, qualityThreshold = 0, epsilonOpen = NULL, sdSplitRead = 0.5, 
    usingPairedEnds = TRUE) 
{
    if (is.na(dirBamFile)) 
        dirBamFile <- "./"
    if (substr(dirBamFile, length(dirBamFile), 1) != "/") 
        dirBamFile <- paste(dirBamFile, "/", sep = "")
    if (is.null(windows)) 
        stop("Please input windows used in the read-depth based approach")
    if (is.null(chr)) 
        stop("Please input chr")
    if (is.null(epsilonOpen)) 
        epsilonOpen <- 2 * windows
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
                1, 3]) | (resultFromRD[kk, 5] != resultFromRD[kk - 
                1, 5])) {
                tempGroup[kk:(length(tempGroup))] <- nAA
                nAA <- nAA + 1
            }
        }
    }
    names(tempGroup) <- resultFromRD[, 1]
    groupFromRD <- as.numeric(names(table(tempGroup)))
    groupTableFromRD <- cbind(resultFromRD, tempGroup)
    Nnormal <- dim(normalGroup)[1]
    finalResultSplitAndRead <- data.frame(normalGroup, rep("NORMAL", 
        Nnormal), rep("NORMAL", Nnormal), rep("NORMAL", Nnormal))
    colnames(finalResultSplitAndRead) <- paste("V", 1:dim(finalResultSplitAndRead)[2], 
        sep = "")
    tempDataFrameOut <- NULL
    for (gG in groupFromRD) {
        subGroupFromRD <- names(tempGroup[tempGroup == gG])
        SubgroupTableFromRD <- groupTableFromRD[groupTableFromRD[, 
            dim(groupTableFromRD)[2]] == gG, ]
        tempSplitOut <- getSplitScoreForGroup(dirBamFile = dirBamFile, 
            listFile = SubgroupTableFromRD[, 1], chr = chr, windows = windows, 
            typeSV = toupper(as.character(SubgroupTableFromRD[, 
                5])[1]), medLeft = SubgroupTableFromRD[, 2][1], 
            medRight = SubgroupTableFromRD[, 3][1], sdSplitRead = 0.5, 
            epsilonOpen = epsilonOpen, usingPairedEnds = usingPairedEnds)
        tempDataFrameOut <- rbind(tempDataFrameOut, data.frame(SubgroupTableFromRD, 
            rep(tempSplitOut$splitBreak[1], dim(SubgroupTableFromRD)[1]), 
            rep(tempSplitOut$splitBreak[2], dim(SubgroupTableFromRD)[1])))
    }
    if (!is.null(tempDataFrameOut)) {
        colnames(tempDataFrameOut) <- paste("V", 1:dim(finalResultSplitAndRead)[2], 
            sep = "")
        ppOut <- rbind(apply(finalResultSplitAndRead, 2, as.character), 
            apply(tempDataFrameOut, 2, as.character))
    }
    else ppOut <- apply(finalResultSplitAndRead, 2, as.character)
    return(ppOut)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
