library(dplyr); library(rvest); library(stringr); library(lubridate); library(readr)

# Get HTML of page of all procurement projects (method: blank search)
page.html <- read_html("http://procurement.atlantaga.gov/?s=&submit=Search")

# Get data_frame (title, link) of each project
projects <- 
     page.html %>% html_nodes("strong a") %>% html_attrs() %>% 
     lapply(function(x) data_frame(href = x[1], title = x[2])) %>% bind_rows()

# This function is for extracting the date/time from the sentence on a project page
# that has 'Posted on / Modified on' info
get_project_datetime <- function(project_page){
     project_page.html <- project_page %>% read_html()
     
     postedstring <- project_page.html %>% html_nodes("h2, p") %>% html_text() %>% 
          .[str_detect(., "[Pp]osted on")] %>% str_replace_all("\\n", "")
     
     get_datetime <- function(x){
          x_clean <- x %>% str_sub(1, -5) %>% str_replace(" at ", " ")
          return(mdy_hm(x_clean, tz = str_sub(x, -3, -1)))
     }
     postedon <- 
          postedstring %>% 
          str_extract("(?<=Posted on \\w{6,9}, ).+(?=\\.\\s{1,2})") %>%
          get_datetime()
     lastmodified <- 
          postedstring %>% 
          str_extract("(?<=Last modified \\w{6,9}, ).+(?=\\.)") %>%
          get_datetime()
     return(data_frame(postedon = postedon, lastmodified = lastmodified))
}

projects_datetimes <- vector(mode = "list", length = length(projects$href))

for(i in seq_along(projects$href)){
     print(paste0("Getting # ", i, " of ", nrow(projects), ": ", projects$title[i]))
     projects_datetimes[[i]] <- get_project_datetime(projects$href[i])
}

projects_data <- 
     bind_cols(projects, bind_rows(projects_datetimes)) %>% 
     mutate(project_num = str_extract(title, pattern = "\\w+- {0,1}\\w+(?=)")) %>%
     select(title, postedon, lastmodified, link = href)

print("Writing project data to atlanta_procurement_projects.csv")
write_csv(projects_data, "atlanta_procurement_projects.csv")
