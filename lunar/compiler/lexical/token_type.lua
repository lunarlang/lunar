return {
  none = 0,

  whitespace_trivia = 1,
  end_of_line_trivia = 2,

  -- tokens with any values (1xx)
  identifier = 100,

  -- keywords (2xx)
  and_keyword = 200,
  break_keyword = 201,
  do_keyword = 202,
  else_keyword = 203,
  elseif_keyword = 204,
  end_keyword = 205,
  false_keyword = 206,
  for_keyword = 207,
  function_keyword = 208,
  if_keyword = 209,
  in_keyword = 210,
  local_keyword = 211,
  nil_keyword = 212,
  not_keyword = 213,
  or_keyword = 214,
  repeat_keyword = 215,
  return_keyword = 216,
  then_keyword = 217,
  true_keyword = 218,
  until_keyword = 219,
  while_keyword = 220
}
