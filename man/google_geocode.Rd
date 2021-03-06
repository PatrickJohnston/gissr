% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/google_geocode.R
\name{google_geocode}
\alias{google_geocode}
\title{Function to find latitude and longitude pairs from an address-string using 
Google Maps API.}
\usage{
google_geocode(input, source = "google", override_limit = TRUE)
}
\arguments{
\item{source}{What API should \code{google_geocode} access? Options are 
"google" or "dsk" and the default is "google".}

\item{override_limit}{Should the function attempt to override the 2500 queries
a day limit? This does not always work.}

\item{string}{The address string to transform to latitude and longitude pairs.}
}
\description{
The Google Maps API is not open-source, therefore check the licensing 
conditions for usage conditions 
(\url{https://developers.google.com/maps/terms}). Users of this function 
must use the geocoded data to display on a Google Map.
}
\details{
\code{google_geocode} is a wrapper for \code{ggmap::geocode} with some simple 
enhancements to clean the output and avoid messages to the console. Other 
address elements such as postcodes can also be transformed successfully.
}
\examples{
\dontrun{

google_geocode("bath abbey")
string     address                                                    latitude longitude
bath abbey bath abbey, bath, bath and north east somerset ba1 1lt, uk 51.38148 -2.358735

}

}
\author{
Stuart K. Grange
}

