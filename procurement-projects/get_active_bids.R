library(tidyverse); library(rvest)
p <- read_html("http://procurement.atlantaga.gov/solicitations/")
p %>% html_nodes("#project-solicitations") %>% .[[1]]

p1 <- read_html("http://procurement.atlantaga.gov/?json=get_tag_posts&tag_slug=citywide")

# Get JSON file of all procurement projects
projects_raw <- httr::GET("http://procurement.atlantaga.gov/?json=get_category")
projects <- httr::content(projects_raw)

parse_unixts_or_ymdhms <- function(x) {
  case_when(
    str_detect(x, "\\d{10}") ~ as.POSIXct(as.numeric(x), origin = "1970-01-01", tz = "UTC"),
    str_detect(x, "^\\d{4}-\\d{2}-\\d{2} \\d\\d:\\d\\d:\\d\\d") ~ ymd_hms(x, tz = "UTC"))
}

projects_parsed <- 
bind_rows(
  map(projects$posts, ~c(post_id = .$id, post_url = .$url, post_title = .$title, .$author, .$comments, 
                         post_date = .$date, post_modified = .$modified,
                                 solicitation_status = .$custom_fields$solicitation_status[[1]],
                                 bids_due = .$custom_fields$bids_due[[1]],
                                 questions_due = .$custom_fields$questions_due[[1]]))
  ) %>%
  mutate_at(vars(bids_due, questions_due), funs(parse_unixts_or_ymdhms))
