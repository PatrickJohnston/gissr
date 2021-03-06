% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sp_length.R
\name{sp_length}
\alias{sp_length}
\title{Function to find a spatial object's length in metres or kilometres.}
\usage{
sp_length(sp, unit = "m", features = TRUE)
}
\description{
\code{sp_length} is a wrapper for \code{rgeos::gLength} and calculates the 
lengths of spatial lines or polygons. If \code{sp_length} is used with 
polygons, it returns the length of the perimeter of the polygons.
}
\details{
The trigonometric function, \code{geosphere::perimeter} performs poorly for 
length calculations. Therefore, when spatial objects are used with 
\code{sp_length} which have projection systems without metre units (such as 
WGS84), the Mollweide projection system is used by default. The Mollweide 
projection is applicable in any location on Earth, but the accuracy of the 
returned values is dependent on location.

If the spatial objects are located in a zone which has a more appropriate 
projection system, it is highly recommended that this is used. For example, 
spatial data in New Zealand should be projected in the New Zealand Transverse 
Mercator 2000 while data in the UK should be projected in British National 
Grid; both of which have metre units (\code{+units=m}).
}
\author{
Stuart K. Grange
}

