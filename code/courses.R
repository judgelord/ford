
library(tidyverse)
library(rvest)
library(magrittr)

term = "fall/2025"


url <- "https://fordschool.umich.edu/courses"


html <- read_html(url) # The course homepage
links <- html_nodes(html, "a") # "a" nodes are linked text

pages <- courses |>
  html_nodes("a") |>
  html_attr("href")

d <- tibble(title = html_text(links),
            url = html_attr(links, "href")
)

pages <- d |> filter(str_detect(title, "Last page")) |>
  pull(url) |>
  str_extract("[0-9]+") |>
  as.numeric()

courses <- d |>
  filter(str_detect(url, "course/"))

for(i in 0:pages){

  url_i <- paste0("https://fordschool.umich.edu/courses?page=", i)
  html <- read_html(url_i) # The course homepage
  links <- html_nodes(html, "a") # "a" nodes are linked text

  d <- tibble(title = html_text(links),
              url = html_attr(links, "href")
  )

  courses <<- full_join(courses,
                        d |>  filter(str_detect(url, "course/"))
  )

}

save(courses,
     file = here::here("data", "courses.rda"))



current <- filter(courses, str_detect(url, term) )

for(i in 1:nrow(current)){
url <-  paste0("https://fordschool.umich.edu", current$url[i])
html <- read_html(url) # The course homepage
links <- html_nodes(html, "a") # "a" nodes are linked text

html |> #html_element("p") %>%
  html_text2() |>
  as.character() |>
  stringr::str_remove_all("(\n|.)*PubPol|\nTerm\n(\n|.)*\nCredit Hours|\nTo see additional course meeting information, please\n\nlogin with your U-M Level 1 password\n\nLevel|\nShare:\n(\n|.)*|Faculty Expert") |>
knitr::kable()

# TODO
# d <- tibble(title = html_text(links),
#             url = html_attr(links, "href")
}

