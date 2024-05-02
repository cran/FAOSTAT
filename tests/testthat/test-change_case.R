context("Ensure that change case works consistently")

test_that("Snake case converts correctly",{
  
  expect_equal(to_snake("nochange"), "nochange")
  expect_equal(to_snake("^snake*"), "_snake_")
  expect_equal(to_snake("snAke"), "snake")
  expect_equal(to_snake("snake case"), "snake_case")
  expect_equal(to_snake(""), "")
  
  expect_equal(to_snake(NA_character_), NA_character_)
  
  
})
