#' Function to promoting a data frame to a SpatialPointsDataFrame, 
#' SpatialLinesDataFrame, or SpatialPolygonsDataFrame.
#' 
#' @param df Data frame to be converted into spatial data frame.  
#' 
#' @param latitude \code{df}'s latitude variable name. 
#' 
#' @param longitude \code{df}'s longitude variable name.
#' 
#' @param projection \code{df}'s latitude and longitude projection system. 
#' Default is WGS84.
#' 
#' @param id Variable in \code{df} which codes for spatial object's id. This is
#' used when a data frame contains many seperate geometries. \code{id} is not 
#' used for points because each point is a seperate geometry. 
#' 
#' @param type Type of geomerty. Type must be one of \code{"points"}, 
#' \code{"lines"}, or \code{"polygons"} and there is no default. 
#' 
#' @author Stuart K. Grange
#' 
#' @return A SpatialPointsDataFrame, SpatialLinesDataFrame, or 
#' SpatialPolygonsDataFrame.
#' 
#' @seealso \code{\link{sp_from_wkt}}
#' 
#' @examples 
#' \dontrun{
#' 
#' # Promote to different geometry types
#' # Points
#' sp_points <- sp_from_data_frame(data_drawn, type = "points")
#' 
#' # Lines
#' sp_lines <- sp_from_data_frame(data_drawn, type = "lines")
#' # Lines with seperate geometries
#' sp_lines <- sp_from_data_frame(data_drawn, type = "lines", id = "name")
#' 
#' # Polygons
#' sp_polygons <- sp_from_data_frame(data_drawn, type = "polygons")
#' # Polygons with seperate geometries
#' sp_polygons <- sp_from_data_frame(data_drawn, type = "polygons", id = "name")
#' 
#' }
#' 
#' @export
sp_from_data_frame <- function(df, latitude = "latitude", 
                               longitude = "longitude", 
                               projection = "+proj=longlat +datum=WGS84 +no_defs",
                               id = NA,
                               type) {
  
  #  Check and parse
  if (length(type) != 1) stop("'type' must have a length of one. ", call. = FALSE)
  
  # Make plurals
  type <- stringr::str_to_lower(type)
  type <- ifelse(type == "point", "points", type)
  type <- ifelse(type == "line", "lines", type)
  type <- ifelse(type == "polygon", "polygons", type)
  
  # Check
  if (!grepl("points|lines|polygons", type)) 
    stop("'type' must be one of 'points', 'lines', or 'polygons'.", call. = FALSE)
  
  # Promote to spatial data
  if (type == "points") {
    
    sp <- data_frame_to_points(df, latitude, longitude, projection)
    
  }
  
  if (type == "lines") {
    
    sp <- data_frame_to_lines(df, latitude, longitude, projection, id)
    
  }
  
  if (type == "polygons") {
    
    sp <- data_frame_to_polygons(df, latitude, longitude, projection, id)
    
  }
  
  # Return
  sp
  
}


data_frame_to_points <- function(df, latitude, longitude, projection) {
  
  # Catch for dplyr's data frame class
  df <- threadr::base_df(df)
  
  # Make sp points object
  sp::coordinates(df) <- c(longitude, latitude)
  
  # Reassign
  sp <- df
  
  # Give the object a projection
  if (!is.na(projection)) sp <- sp_transform(sp, projection, warn = FALSE)
  
  # Return
  sp
  
}



data_frame_to_lines <- function(df, latitude, longitude, projection, id) {
  
  # Catch for dplyr's data frame class
  df <- threadr::base_df(df)
  
  # Make an identifier variable for lines
  if (is.na(id)) {
    
    # Single line object, no grouping
    df[, "id"] <- 1
    
  } else {
    
    # Use input variable
    df[, "id"] <- df[, id]
    
  }
  
  # Get data part for the SpatialLinesDataFrame
  data_extras <- dplyr::distinct(df, id)
  
  # Make sp points object
  sp_object <- data_frame_to_points(df, latitude, longitude, projection)
  
  # From
  # http://stackoverflow.com/questions/24284356/convert-spatialpointsdataframe-
  # to-spatiallinesdataframe-in-r
  # Generate lines for each id
  lines <- lapply(split(sp_object, sp_object$id), function(x) 
    Lines(list(Line(sp::coordinates(x))), x$id[1L]))
  
  # Drop
  if (!is.na(id)) data_extras[, "id"] <- NULL
  
  # Create SpatialLines
  sp <- sp::SpatialLines(lines)
  
  # Make SpatialLinesDataFrame
  sp <- sp::SpatialLinesDataFrame(sp, data_extras, match.ID = FALSE)
  
  # Give the object a projection
  if (!is.na(projection)) sp <- sp_transform(sp, projection, warn = FALSE)
  
  # Return
  sp
  
}



data_frame_to_polygons <- function(df, latitude, longitude, projection, id) {
  
  # Catch for dplyr's data frame class
  df <- threadr::base_df(df)
  
  # Make an identifier variable for lines
  if (is.na(id)) {
    
    # Single line object, no grouping
    df[, "id"] <- 1
    
  } else {
    
    # Use input variable
    df[, "id"] <- df[, id]
    
  }
  
  # Get data part for the SpatialLinesDataFrame
  data_extras <- dplyr::distinct(df, id)
  
  # Make sp points object
  sp <- data_frame_to_points(df, latitude, longitude, projection)
  
  # A list element will represent each group within a feature 
  # Long-lat order is important
  coordinates <- plyr::dlply(df, "id", function(x) 
    data.matrix(x[, c(longitude, latitude)]))
  
  # Make polygons
  sp <- lapply(seq_along(coordinates), function(x) 
    matrix_to_sp_polygon(coordinates[x], x))
  
  # Bind geometries
  sp <- do.call(rbind, sp)
  
  # Make sp dataframe
  sp <- sp::SpatialPolygonsDataFrame(sp, data_extras)
  
  # Give the object a projection
  if (!is.na(projection)) sp <- sp_transform(sp, projection, warn = FALSE)
  
  # Return
  sp
  
}


# No export
matrix_to_sp_polygon <- function(matrix, id) {
  
  # Matix to polygon
  polygon <- Polygon(matrix)
  
  # Polygon to polygons
  polygon <- Polygons(list(polygon), id)
  
  # To spatial polygons
  sp <- sp::SpatialPolygons(list(polygon))
  
  # Return
  sp
  
}
