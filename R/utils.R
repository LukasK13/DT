dropNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

isFALSE = function(x) identical(x, FALSE)

is.Date = function(x) inherits(x, c('Date', 'POSIXlt', 'POSIXct'))

# for CSS propertices: fontWeight -> font-weight, backgroundColor ->
# background-color, etc
upperToDash = function(x) {
  x = gsub('^(.)', '\\L\\1', x, perl = TRUE)
  x = gsub('([A-Z])', '-\\L\\1', x, perl = TRUE)
  x
}

inShiny = function() {
  getOption('DT.datatable.shiny', FALSE) ||
    ('shiny' %in% loadedNamespaces() && !is.null(shiny::getDefaultReactiveDomain()))
}

in_dir = function(dir, expr) {
  owd = setwd(dir); on.exit(setwd(owd))
  expr
}

existing_files = function(x) x[file.exists(x)]

# generate <caption></caption>
captionString = function(caption) {
  if (is.character(caption)) caption = tags$caption(caption)
  caption = as.character(caption)
  if (length(caption)) caption
}

toJSON = function(...) {
  FUN = getFromNamespace('toJSON', 'htmlwidgets')
  FUN(...)
}

native_encode = function(x) {
  if (.Platform$OS.type == 'unix') return(x)
  x2 = enc2native(x)
  if (identical(enc2utf8(x2), x)) x2 else x
}

classes = function(x) paste(class(x), collapse = ', ')

#' Coerce a character string to the same type as a target value
#'
#' Create a new value from a character string based on an old value, e.g., if
#' the old value is an integer, call \code{as.integer()} to coerce the string to
#' an integer.
#'
#' This function only works with integer, double, date, time (\code{POSIXlt} or
#' \code{POSIXct}), and factor values. The date must be of the format
#' \code{\%Y-\%m-\%dT\%H:\%M:\%SZ}. The factor value must be in the levels of
#' \code{old}, otherwise it will be coerced to \code{NA}.
#' @param val A character string.
#' @param old An old value, whose type is the target type of \code{val}.
#' @export
#' @return A value of the same data type as \code{old} if possible.
#' @examples library(DT)
#' coerceValue('100', 1L)
#' coerceValue('1.23', 3.1416)
#' coerceValue('2018-02-14', Sys.Date())
#' coerceValue('2018-02-14T22:18:52Z', Sys.time())
#' coerceValue('setosa', iris$Species)
#' coerceValue('setosa2', iris$Species)  # NA
#' coerceValue('FALSE', TRUE)  # not supported
coerceValue = function(val, old) {
  if (is.integer(old)) return(as.integer(val))
  if (is.numeric(old)) return(as.numeric(val))
  if (inherits(old, 'Date')) return(as.Date(val))
  if (inherits(old, c('POSIXlt', 'POSIXct'))) {
    val = strptime(val, '%Y-%m-%dT%H:%M:%SZ', tz = 'UTC')
    if (inherits(old, 'POSIXlt')) return(val)
    return(as.POSIXct(val))
  }
  if (is.factor(old)) {
    if (val %in% levels(old)) return(val)
    warning(
      'New value ', val, ' not in the original factor levels: ',
      paste(levels(old), collapse = ', ')
    )
    return(NA)
  }
  warning('The data type is not supported: ', classes(old))
  val
}
