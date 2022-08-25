library(ggplot2)
library(dplyr)
#install.packages("tidyverse")
library(tidyverse)
bikes <- readr::read_csv(
  here::here("data", "london-bikes-custom.csv"),
  ## or: "https://raw.githubusercontent.com/z3tt/graphic-design-ggplot2/main/data/london-bikes-custom.csv"
  col_types = "Dcfffilllddddc"
)

bikes$season <- forcats::fct_inorder(bikes$season)

ggplot(data = bikes) + 
  aes(x = temp_feel, y = count)

#same as:
# ggplot(data = bikes, mapping = aes(x = temp_feel, y = count))
# or
# ggplot(bikes, aes(temp_feel, count))
# or
# ggplot(bikes, aes(x = temp_feel, y = count))

## Aesthetics (aes) link variables in the data frame to graphical properties:
## position, color, shape, size, transparency

## Geoms interpret aesthetics as graphical representations

ggplot(data = bikes) + 
  aes(x = temp_feel, y = count) + 
  geom_point()

# Within a geom, you can set visual properties
ggplot(data = bikes) + 
  aes(x = temp_feel, y = count) + 
  geom_point(
    color = "#28a87d",
    alpha = 0.5,
    shape = "X",
    stroke = 1,
    size = 4
  )

# You can also *map* visial properties with an aesthetic in the geom:
ggplot(data = bikes) + 
  aes(x = temp_feel, y = count) + 
  geom_point(
    aes(color = season),
    alpha = 0.5
  )

# Epxressions can be mapped, too:
ggplot(data = bikes) + 
  aes(x = temp_feel, y = count) + 
  geom_point(
    aes(color = temp_feel>20),
    alpha = 0.5
  )

## An assignment: create a scatter plot of temp_feel v. temp.
### Map the color of the points to clear weather, map the size to count, 
### and turn the points into diamonds.

ggplot(data = bikes) + 
  aes(x = temp_feel, y = temp) + 
  geom_point(
    aes(color = weather_type == "clear",
        size = count),
    shape = "diamond",
    alpha = 0.5
    )

## If you don't want the "NA" for weather in the legend above, filter first:
bikes %>%
  filter(!is.na(weather_type)) %>%
  ggplot(data = ., aes(x = temp_feel, y = temp)) +
  geom_point(
    aes(color = weather_type == "clear",
        size = count),
    shape = "diamond",
    alpha = 0.5
  )

## Placing the aesthetic within the geom means that it will be limited to that geom.
## Placing the aesthetic within the call to ggplot will make it universal. This
## is useful when you add layers and want the same aesthetic.
ggplot(
  bikes,
  aes(x = temp_feel, y = count
      )
) +
  geom_point(
    aes(color = season),
    alpha = .5
  ) +
  geom_smooth(
    method = "lm"
  )

# vs a global aesthetic:
ggplot(
  bikes,
  aes(x = temp_feel, y = count,
      color = season
      )
) +
  geom_point(
    alpha = .5
  ) +
  geom_smooth(
    method = "lm"
  )

# Similarly, 'groups' can be defined globally or locally:
# Local:
ggplot(
  bikes,
  aes(x = temp_feel, y = count)
) +
  geom_point(
    aes(color = season),
    alpha = .5
  ) +
  geom_smooth(
    aes(group = day_night),
    method = "lm"
  )
# Global:
ggplot(
bikes,
aes(x = temp_feel, y = count,
    color = season,
    group = day_night)
) +
  geom_point(
    alpha = .5
  ) +
  geom_smooth(
    method = "lm"
  )

# Even with global mapping, you can stil set properties locally, 
# like if you wanted to change line color for the smooth:
ggplot(
  bikes,
  aes(x = temp_feel, y = count,
      color = season,
      group = day_night)
) +
  geom_point(
    alpha = .5
  ) +
  geom_smooth(
    method = "lm",
    color = "black"
  )

# stats and geoms can interchange to produce same output. This:
ggplot(bikes, aes(x = temp_feel, y = count)) +
  stat_smooth(geom = "smooth")

# is the same as:
ggplot(bikes, aes(x = temp_feel, y = count)) +
  geom_smooth(stat = "smooth")

# Just as this:
ggplot(bikes, aes(x = season)) +
  stat_count(geom = "bar")

# is the same as:
ggplot(bikes, aes(x = season)) +
  geom_bar(stat = "count")

# or:
ggplot(bikes, aes(x = date, y = temp_feel)) +
  stat_identity(geom = "point")

#and:
ggplot(bikes, aes(x = date, y = temp_feel)) +
  geom_point(stat = "identity")

## ggplot can produce summaries of data:
ggplot(
  bikes, 
  aes(x = season, y = temp_feel)
) +
  stat_summary() 

## stat summary can be added to other geoms:
ggplot(
  bikes, 
  aes(x = season, y = temp_feel)
) +
  geom_boxplot() +
  stat_summary(
    fun = mean,
    geom = "point",
    color = "#28a87d",
    size = 3
  ) 

## create your own summaries:
ggplot(
  bikes, 
  aes(x = season, y = temp_feel)
) + 
  stat_summary(
    fun = mean,
    fun.max = function(y) mean(y) + sd(y),
    fun.min = function(y) mean(y) - sd(y)
  )

# Storing ggplot as objects can allow for inspection.
g <-
  ggplot(
    bikes,
    aes(x = temp_feel, y = count,
        color = season,
        group = day_night)
  ) +
  geom_point(
    alpha = .5
  ) +
  geom_smooth(
    method = "lm",
    color = "black"
  )

class(g)
# Take a look:
g$data
g$layers
g$mapping

# You can also add layers to your object.
g + 
  geom_rug(
    alpha = 0.2
  )

# Labelling!
g + 
  labs(
    x = "Feels-like temperature (°F)",
    y = "Reported bike shares",
    title = "Bike sharing trends",
    subtitle = "Reported bike rentals versus apparent temperature",
    caption = "Data from TfL",
    color = "Season:", ##handy trick for relabeling the legend!
    tag = "Fig. 1" 
  )

# Themes change the appearance of the plot.Let's make a simpler version of the above:
g <-
g + 
  labs(
    x = "Feels-like temperature (°F)",
    y = "Reported bike shares",
    title = "Bike sharing trends",
    color = "Season:", ##handy trick for relabeling the legend!
  )

g + theme_light()
g + theme_minimal()
g + theme_dark()
g + theme_classic()
g + theme_bw()

# Make the font bigger, or override other theme defaults:
g + theme_light(
  base_size = 14
)

#if you want to set a theme globally: 
## theme_set(theme_light())

library(systemfonts)
system_fonts() %>%
  filter(str_detect(family, "Cabinet")) %>%
  pull(name) %>%
  sort()
system_fonts()

